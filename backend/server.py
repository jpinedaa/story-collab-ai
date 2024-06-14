import json
import os

from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

GAME_STATE_FILE = 'game_state.json'
INITAL_GAME_STATE = {
    "players": [],
    "sceneAndMoves": []
}


# Load game state from a JSON file
def load_game_state():
    if os.path.exists(GAME_STATE_FILE):
        with open(GAME_STATE_FILE, 'r') as file:
            return json.load(file)
    return INITAL_GAME_STATE


# Save game state to a JSON file
def save_game_state(game_state):
    with open(GAME_STATE_FILE, 'w') as file:
        json.dump(game_state, file, indent=4)


@app.route('/gamestate', methods=['GET'])
def get_game_state():
    game_state = load_game_state()
    return jsonify(game_state)

@app.route('/gamestate', methods=['POST'])
def update_game_state():
    game_state = request.json
    save_game_state(game_state)
    return jsonify(game_state)

@app.route('/gamestate/reset', methods=['POST'])
def reset_game_state():
    initial_state = INITAL_GAME_STATE
    save_game_state(initial_state)
    return jsonify(initial_state)

if __name__ == '__main__':
    app.run(debug=True)
