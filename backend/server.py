import json
import os
import re
from flask import Flask, request, jsonify
from flask_cors import CORS
from cryptography.fernet import Fernet
from langchain_nvidia_ai_endpoints import ChatNVIDIA


app = Flask(__name__)
CORS(app)

INITIAL_GAME_STATE = {
    "players": [],
    "sceneAndMoves": [],
    "cards": [],
}

SETTINGS_FILE = 'settings.json'
SECRET_KEY = b'sEWCO3d4dV28LBuepu_Cvjjsv61xEawNeMIQA8GwlQI='  # Hardcoded key for encryption
cipher_suite = Fernet(SECRET_KEY)


def get_model():
    settings = load_settings()
    if 'apiKey' in settings:
        os.environ["NVIDIA_API_KEY"] = settings['apiKey']
    if 'model' in settings:
        return ChatNVIDIA(model=settings['model'])
    return


def clean_json(json_string):
    json_string = re.sub(r',\s*([\]}])', r'\1', json_string)
    return json_string

def load_game_state(file_path):
    if os.path.exists(file_path):
        with open(file_path, 'r') as file:
            return json.load(file)
    return INITIAL_GAME_STATE

def save_game_state(game_state, file_path):
    json_string = json.dumps(game_state, indent=4)
    cleaned_json_string = clean_json(json_string)
    with open(file_path, 'w') as file:
        file.write(cleaned_json_string)

def encrypt_data(data):
    json_string = json.dumps(data)
    encrypted_data = cipher_suite.encrypt(json_string.encode())
    return encrypted_data

def decrypt_data(encrypted_data):
    decrypted_data = cipher_suite.decrypt(encrypted_data)
    return json.loads(decrypted_data.decode())

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

    initial_state = INITIAL_GAME_STATE
    save_game_state(initial_state, game_state_file)
    return jsonify(initial_state)

def load_settings():
    if os.path.exists(SETTINGS_FILE):
        with open(SETTINGS_FILE, 'rb') as file:
            encrypted_data = file.read()
            settings = decrypt_data(encrypted_data)
            return settings
    return {}

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

if __name__ == '__main__':
    app.run(debug=True)
