from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Dummy game state
game_state = {
    "players": [
        {"name": "Alice", "role": "Narrator", "status": "active"},
        {"name": "Bob", "role": "Player", "status": "active"},
        {"name": "Charlie", "role": "Player", "status": "inactive"}
    ],
    "currentSceneDescription": """
    As you step into the ancient forest, a sense of wonder and trepidation fills your heart...
    """,
    "currentMoves": [
        "Player A decides to solve the riddles.",
        "Player B engages in combat with the shadowy figures.",
        "Player C confronts their deepest fears and insecurities."
    ],
    "isNarrator": True
}

@app.route('/gamestate', methods=['GET'])
def get_game_state():
    return jsonify(game_state)

@app.route('/gamestate', methods=['POST'])
def update_game_state():
    global game_state
    game_state = request.json
    return jsonify(game_state)

if __name__ == '__main__':
    app.run(debug=True)
