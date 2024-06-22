import threading
import time
import requests
import subprocess
import os
from server import app


def run_flask_app():
    app.run(port=5000)  # Ensure this matches your Flask server's settings


def check_server():
    """Check server status."""
    try:
        response = requests.get("http://localhost:5000/health")
        return response.status_code == 200
    except requests.ConnectionError:
        return False


def start_frontend():
    current_dir = os.path.dirname(os.path.abspath(__file__))
    frontend_path = os.path.join(current_dir, "frontend/narravive.exe")
    print(f"Starting frontend at {frontend_path}")
    subprocess.call([frontend_path])


def main():
    # Start Flask app in a separate thread
    threading.Thread(target=run_flask_app, daemon=True).start()
    print("Server is starting...")

    # Wait for the server to be ready
    while not check_server():
        print("Waiting for server to be ready...")
        time.sleep(1)

    print("Server is ready.")
    start_frontend()


if __name__ == "__main__":
    main()
