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
    Serial.println("\n--- MODO FRAGMENTADO (Bye Bye Packet Drops) ---");

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

    Serial.println(">>> Fragmentando...");
    String b64 = base64::encode(fb->buf, fb->len);
    esp_camera_fb_return(fb);

    String fid = String(millis());
    int chunkSize = 400; // Super pequeno para nao cair nunca
    int total = (b64.length() + chunkSize - 1) / chunkSize;

    for (int i = 0; i < total; i++) {
        String partData = b64.substring(i * chunkSize, (i + 1) * chunkSize);
        String url = String(serverUrl) + "/upload-fragment?id=" + fid + "&part=" + String(i) + "&total=" + String(total) + "&data=" + urlEncode(partData);
        
        Serial.printf(">>> Enviando Parte %d/%d...\n", i+1, total);
        
        HTTPClient http;
        http.begin(url);
        int code = http.GET();
        Serial.printf(" Resposta: %d\n", code);
        http.end();
        
        delay(300); // Respiro para a rede 4G nao surtar
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
    delay(3000); 
}
