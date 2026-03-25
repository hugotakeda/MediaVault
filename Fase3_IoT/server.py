import os
import time
import json
from flask import Flask, request, jsonify, render_template, send_from_directory

app = Flask(__name__, template_folder=".", static_folder="static")

# ---------------------------------------------------------
# Configurações do Projeto NAS Familiar
# ---------------------------------------------------------
BASE_DIR = "/home/nasadmin/Fase3_IoT"
CAPTURES_DIR = os.path.join(BASE_DIR, "static/captures")
LOG_JSON_PATH = os.path.join(BASE_DIR, "iot_logs.json")

# Polling State
pending_upload = False

# Garante que os diretórios existem
os.makedirs(CAPTURES_DIR, exist_ok=True)

if not os.path.exists(LOG_JSON_PATH):
    with open(LOG_JSON_PATH, "w") as f:
        json.dump([], f)

@app.route("/upload-event", methods=["POST"])
def nextcloud_webhook():
    global pending_upload
    print("[!] Webhook: Trigger recebido do Nextcloud.")
    pending_upload = True
    return {"status": "success", "message": "Trigger set for ESP32 polling"}

@app.route("/poll-upload", methods=["GET"])
def poll_upload():
    global pending_upload
    if pending_upload:
        pending_upload = False
        print("[!] Polling: ESP32 solicitou trigger - Enviando...")
        return {"status": "trigger"}
    return {"status": "idle"}

@app.route("/upload-photo", methods=["POST"])
def upload_photo():
    try:
        data = request.get_data()
        if not data:
            return {"status": "error", "message": "Sem dados"}, 400
            
        filename = f"capture_{int(time.time())}.jpg"
        filepath = os.path.join(CAPTURES_DIR, filename)
        
        with open(filepath, "wb") as f:
            f.write(data)
            
        log_entry = {
            "image": filename,
            "user": "Familiar (Captura IoT)",
            "type": "foto",
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
        }
        
        with open(LOG_JSON_PATH, "r") as f:
            logs = json.load(f)
        logs.insert(0, log_entry)
        with open(LOG_JSON_PATH, "w") as f:
            json.dump(logs[:50], f)
            
        print(f"[+] Foto salva com sucesso: {filename}")
        return {"status": "success", "filename": filename}
    except Exception as e:
        print(f"[-] Erro no upload: {e}")
        return {"status": "error", "message": str(e)}, 500

@app.route("/", methods=["GET"])
def index():
    return render_template("dashboard_iot.html")

@app.route("/api/logs", methods=["GET"])
def get_logs():
    if os.path.exists(LOG_JSON_PATH):
        with open(LOG_JSON_PATH, "r") as f:
            return jsonify(json.load(f))
    return jsonify([])

# Rota para servir as imagens capturadas
@app.route("/static/captures/<path:filename>")
def serve_capture(filename):
    return send_from_directory(CAPTURES_DIR, filename)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
