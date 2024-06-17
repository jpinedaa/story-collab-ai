from cryptography.fernet import Fernet
from langchain_nvidia_ai_endpoints import ChatNVIDIA
import json
import os


base_dir = os.path.dirname(os.path.abspath(__file__))
SETTINGS_FILE = os.path.join(base_dir,'settings.json')
SECRET_KEY = b'sEWCO3d4dV28LBuepu_Cvjjsv61xEawNeMIQA8GwlQI='  # Hardcoded key for encryption
cipher_suite = Fernet(SECRET_KEY)


def encrypt_data(data):
    json_string = json.dumps(data)
    encrypted_data = cipher_suite.encrypt(json_string.encode())
    return encrypted_data

def decrypt_data(encrypted_data):
    decrypted_data = cipher_suite.decrypt(encrypted_data)
    return json.loads(decrypted_data.decode())


def load_settings():
    if os.path.exists(SETTINGS_FILE):
        with open(SETTINGS_FILE, 'rb') as file:
            encrypted_data = file.read()
            settings = decrypt_data(encrypted_data)
            return settings
    return {}


def get_model():
    settings = load_settings()
    if 'apiKey' in settings:
        os.environ["NVIDIA_API_KEY"] = settings['apiKey']
    if 'model' in settings:
        return ChatNVIDIA(model=settings['model'])
    return