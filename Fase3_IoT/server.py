import os
import time
import json
import base64
from flask import Flask, request, jsonify, render_template, send_from_directory

app = Flask(__name__, template_folder=".", static_folder="static")

BASE_DIR = "/home/nasadmin/Fase3_IoT"
CAPTURES_DIR = os.path.join(BASE_DIR, "static/captures")
LOG_JSON_PATH = os.path.join(BASE_DIR, "iot_logs.json")
FRAG_DIR = "/tmp/iot_fragments"

pending_upload = False
os.makedirs(CAPTURES_DIR, exist_ok=True)
os.makedirs(FRAG_DIR, exist_ok=True)

if not os.path.exists(LOG_JSON_PATH):
    with open(LOG_JSON_PATH, "w") as f:
        json.dump([], f)

@app.route("/upload-event", methods=["POST"])
def nextcloud_webhook():
    global pending_upload
    print(">>> [WEBHOOK] Sinal de captura ativado.")
    pending_upload = True
    return {"status": "success"}

@app.route("/poll-upload", methods=["GET"])
def poll_upload():
    global pending_upload
    if pending_upload:
        pending_upload = False
        return {"status": "trigger"}
    return {"status": "idle"}

@app.route("/upload-fragment", methods=["GET"])
def upload_fragment():
    try:
        fid = request.args.get("id")
        part = int(request.args.get("part"))
        total = int(request.args.get("total"))
        data = request.args.get("data")
        
        if not all([fid, data]):
            return {"status": "error", "message": "Missing fields"}, 400
            
        print(f">>> [CHUNK] ID: {fid} | Parte: {part+1}/{total}")
        
        chunk_dir = os.path.join(FRAG_DIR, fid)
        os.makedirs(chunk_dir, exist_ok=True)
        
        with open(os.path.join(chunk_dir, f"{part:03d}"), "w") as f:
            f.write(data)
            
        chunks = os.listdir(chunk_dir)
        if len(chunks) == total:
            print(f">>> [REASSEMBLY] Todas as {total} partes recebidas. Montando...")
            full_b64 = ""
            for i in range(total):
                with open(os.path.join(chunk_dir, f"{i:03d}"), "r") as f:
                    full_b64 += f.read()
            
            image_bytes = base64.b64decode(full_b64.replace(" ", "+"))
            
            filename = f"capture_{int(time.time())}.jpg"
            filepath = os.path.join(CAPTURES_DIR, filename)
            with open(filepath, "wb") as f:
                f.write(image_bytes)
                
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
                
            print(f">>> [SUCESSO] Foto montada e salva: {filename}")
            import shutil
            shutil.rmtree(chunk_dir)
            
            return {"status": "complete", "filename": filename}
        
        return {"status": "received", "part": part}
    except Exception as e:
        print(f">>> [ERRO CHUNK] {e}")
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

@app.route("/static/captures/<path:filename>")
def serve_capture(filename):
    return send_from_directory(CAPTURES_DIR, filename)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOF" && cat << 'EOF' > /Users/hugotakeda/Desktop/Bettio/MediaVault/Fase3_IoT/esp32_camera/esp32_camera.ino
#include "WiFi.h"
#include "esp_camera.h"
#include <HTTPClient.h>
#include <base64.h>

const char* ssid = "NASFamiliar";
const char* password = "japa12345";
const char* serverUrl = "http://representation-missile-billy-auto.trycloudflare.com";

#define PWDN_GPIO_NUM     -1
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM     32
#define SIOD_GPIO_NUM     13
#define SIOC_GPIO_NUM     12
#define Y9_GPIO_NUM       39
#define Y8_GPIO_NUM       36
#define Y7_GPIO_NUM       23
#define Y6_GPIO_NUM       18
#define Y5_GPIO_NUM       15
#define Y4_GPIO_NUM        4
#define Y3_GPIO_NUM       14
#define Y2_GPIO_NUM        5
#define VSYNC_GPIO_NUM    27
#define HREF_GPIO_NUM     25
#define PCLK_GPIO_NUM     19

void setup() {
    Serial.begin(115200);
    delay(2000);
    Serial.println("\n--- MODO FRAGMENTADO (Fragmented Hero) ---");

    camera_config_t config;
    config.ledc_channel = LEDC_CHANNEL_0;
    config.ledc_timer = LEDC_TIMER_0;
    config.pin_d0 = Y2_GPIO_NUM;
    config.pin_d1 = Y3_GPIO_NUM;
    config.pin_d2 = Y4_GPIO_NUM;
    config.pin_d3 = Y5_GPIO_NUM;
    config.pin_d4 = Y6_GPIO_NUM;
    config.pin_d5 = Y7_GPIO_NUM;
    config.pin_d6 = Y8_GPIO_NUM;
    config.pin_d7 = Y9_GPIO_NUM;
    config.pin_xclk = XCLK_GPIO_NUM;
    config.pin_pclk = PCLK_GPIO_NUM;
    config.pin_vsync = VSYNC_GPIO_NUM;
    config.pin_href = HREF_GPIO_NUM;
    config.pin_sccb_sda = SIOD_GPIO_NUM;
    config.pin_sccb_scl = SIOC_GPIO_NUM;
    config.pin_pwdn = PWDN_GPIO_NUM;
    config.pin_reset = RESET_GPIO_NUM;
    config.xclk_freq_hz = 10000000;
    config.pixel_format = PIXFORMAT_JPEG;
    config.frame_size = FRAMESIZE_QQVGA; 
    config.jpeg_quality = 20; 
    config.fb_count = 1;

    if (esp_camera_init(&config) != ESP_OK) {
        Serial.println("Erro na Camera!");
        return;
    }

    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(1000);
        Serial.print(".");
    }
    Serial.println("\nWiFi Conectado!");
}

String urlEncode(String str) {
    String encodedString = "";
    char c;
    char code0;
    char code1;
    for (int i = 0; i < str.length(); i++) {
        c = str.charAt(i);
        if (isalnum(c)) { encodedString += c; }
        else {
            code1 = (c & 0xf) + '0';
            if ((c & 0xf) > 9) { code1 = (c & 0xf) - 10 + 'A'; }
            c = (c >> 4) & 0xf;
            code0 = c + '0';
            if (c > 9) { code0 = c - 10 + 'A'; }
            encodedString += '%';
            encodedString += code0;
            encodedString += code1;
        }
    }
    return encodedString;
}

void captureAndSend() {
    Serial.println(">>> Capturando...");
    camera_fb_t * fb = esp_camera_fb_get();
    if (!fb) return;

    String b64 = base64::encode(fb->buf, fb->len);
    esp_camera_fb_return(fb);

    String fid = String(millis());
    int chunkSize = 400; // Fragmented Hero
    int total = (b64.length() + chunkSize - 1) / chunkSize;

    for (int i = 0; i < total; i++) {
        String partData = b64.substring(i * chunkSize, (i + 1) * chunkSize);
        String url = String(serverUrl) + "/upload-fragment?id=" + fid + "&part=" + String(i) + "&total=" + String(total) + "&data=" + urlEncode(partData);
        
        HTTPClient http;
        http.begin(url);
        http.setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36");
        int code = http.GET();
        http.end();
        delay(300); 
    }
}

void loop() {
    if (WiFi.status() == WL_CONNECTED) {
        HTTPClient http;
        if (http.begin(String(serverUrl) + "/poll-upload")) {
            if (http.GET() == 200) {
                if (http.getString().indexOf("trigger") > -1) { captureAndSend(); }
            }
            http.end();
        }
    }
    delay(4000); 
}
