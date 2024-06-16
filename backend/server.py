import json
import os
import re
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

INITAL_GAME_STATE = {
    "players": [],
    "sceneAndMoves": [],
    "cards": [],
}


def clean_json(json_string):
    # Remove trailing commas from JSON objects and arrays
    json_string = re.sub(r',\s*([\]}])', r'\1', json_string)
    return json_string


# Load game state from a JSON file
def load_game_state(file_path):
    if os.path.exists(file_path):
        with open(file_path, 'r') as file:
            return json.load(file)
    return INITAL_GAME_STATE


# Save game state to a JSON file
def save_game_state(game_state, file_path):
    json_string = json.dumps(game_state, indent=4)
    cleaned_json_string = clean_json(json_string)
    with open(file_path, 'w') as file:
        file.write(cleaned_json_string)


@app.route('/gamestate', methods=['GET'])
def get_game_state():
    file_path = request.args.get('path', '')
    if file_path:
        game_state_file = file_path
    else:
        game_state_file = 'game_state.json'

    game_state = load_game_state(game_state_file)
    return jsonify(game_state)


@app.route('/gamestate', methods=['POST'])
def update_game_state():
    file_path = request.args.get('path', '')
    if file_path:
        game_state_file = file_path
    else:
        game_state_file = 'game_state.json'

    game_state = request.json
    save_game_state(game_state, game_state_file)
    return jsonify(game_state)


@app.route('/gamestate/reset', methods=['POST'])
def reset_game_state():
    directory_path = request.args.get('path', '')
    if directory_path:
        game_state_file = os.path.join(directory_path, 'game_state.json')
    else:
        game_state_file = 'game_state.json'

    initial_state = INITAL_GAME_STATE
    save_game_state(initial_state, game_state_file)
    return jsonify(initial_state)


if __name__ == '__main__':
    app.run(debug=True)
