from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"}), 200

@app.route("/", methods=["GET"])
def index():
    # Obtener variables de entorno
    environment = os.getenv("ENV", "local")
    api_key = os.getenv("API_KEY", "no-key-found")

    return jsonify({
        "message": "Hola mundo",
        "environment": environment,
        "api_key_status": "found" if api_key != "no-key-found" else "missing"
    }), 200

if __name__ == "__main__":
    # Escucha en todas las interfaces para exponer en contenedor
    app.run(host="0.0.0.0", port=5000)