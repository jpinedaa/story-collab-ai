import json
import os
import re
import traceback
from filelock import FileLock
from flask import Flask, request, jsonify
from flask_cors import CORS
from requests.compat import chardet

from story_run import StoryRun
from settings import encrypt_data, decrypt_data, SETTINGS_FILE

from story_run import ManualModeError

app = Flask(__name__)
CORS(app)

INITIAL_GAME_STATE = {
    "players": [],
    "sceneAndMoves": [],
    "cards": [],
    "selectedPlayerIndex": 0,
    "autoMode": 0,
}

base_dir = os.path.dirname(os.path.abspath(__file__))
GAME_STATE_FILE = os.path.join(base_dir, './state/game_state.json')
GAME_STATE_LOCK_FILE = os.path.join(base_dir,'./state/game_state.lock')
lock = FileLock(GAME_STATE_LOCK_FILE)


def clean_json(json_string):
    json_string = re.sub(r',\s*([\]}])', r'\1', json_string)
    return json_string


def load_game_state(file_path):
    if os.path.exists(file_path):
        if file_path == GAME_STATE_FILE:
            with lock:
                with open(file_path, 'r') as file:
                    return json.load(file)
        else:
            with open(file_path, 'r') as file:
                return json.load(file)
    return INITIAL_GAME_STATE


def save_game_state(game_state, file_path):
    json_string = json.dumps(game_state, indent=4)
    #cleaned_json_string = clean_json(json_string)
    if file_path == GAME_STATE_FILE:
        with lock:
            with open(file_path, 'w') as file:
                file.write(json_string)
    else:
        with open(file_path, 'w') as file:
            file.write(json_string)


@app.route('/health')
def health():
    return "OK", 200


@app.route('/gamestate', methods=['GET'])
def get_game_state():
    file_path = request.args.get('path', '')
    if file_path:
        game_state_file = file_path
    else:
        game_state_file = GAME_STATE_FILE

    game_state = load_game_state(game_state_file)
    return jsonify(game_state)


@app.route('/gamestate', methods=['POST'])
def update_game_state():
    file_path = request.args.get('path', '')
    if file_path:
        game_state_file = file_path
    else:
        game_state_file = GAME_STATE_FILE

    game_state = request.json
    save_game_state(game_state, game_state_file)
    return jsonify(game_state)


@app.route('/gamestate/reset', methods=['POST'])
def reset_game_state():
    directory_path = request.args.get('path', '')
    if directory_path:
        game_state_file = os.path.join(directory_path, GAME_STATE_FILE)
    else:
        game_state_file = GAME_STATE_FILE

    initial_state = INITIAL_GAME_STATE
    save_game_state(initial_state, game_state_file)
    return jsonify(initial_state)


@app.route('/settings', methods=['GET'])
def load_settings_response():
    if os.path.exists(SETTINGS_FILE):
        with open(SETTINGS_FILE, 'rb') as file:
            encrypted_data = file.read()
            settings = decrypt_data(encrypted_data)
            return jsonify(settings)
    return jsonify({})


@app.route('/settings', methods=['POST'])
def save_settings():
    settings = request.json
    encrypted_data = encrypt_data(settings)
    with open(SETTINGS_FILE, 'wb') as file:
        file.write(encrypted_data)
    return jsonify(settings)


@app.route('/autorun', methods=['GET'])
def handle_autorun():
    current = request.args.get('selected', '')
    try:
        StoryRun(current).run()
    except ManualModeError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        print(traceback.format_exc())
        if 'Bad Request' in str(e):
            return jsonify({"error": str(e)}), 500
        return jsonify({"error": 'Internal Error, please try again'}), 500
    return jsonify({"status": "Autorun request received"}), 200


if __name__ == '__main__':
    app.run(debug=True)
