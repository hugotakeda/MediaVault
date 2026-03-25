# Diagrama de Arquitetura do Sistema

O diagrama abaixo ilustra como os componentes do projeto se comunicam dentro da rede isolada gerada pelo MacBook. Todo o fluxo acontece *sem internet externa*.

```mermaid
graph TD
    classDef hardware fill:#e1f5fe,stroke:#01579b,stroke-width:2px;
    classDef vm fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px;
    classDef iot fill:#fff3e0,stroke:#e65100,stroke-width:2px;
    classDef user fill:#fce4ec,stroke:#c2185b,stroke-width:2px;

    subgraph "Hardware Host (MacBook)"
        AP[Adaptador Wi-Fi Compartilhado]:::hardware
        AP -->|"Cria Subnet isolada"| LAN(Rede_IoT_NAS 192.168.10.0/24)
    end
    
    subgraph "VM Ubuntu Server (UTM) - 192.168.10.10"
        NC[Nextcloud App / Nginx <br>Porta 80/443]:::vm
        DB[(MariaDB)]:::vm
        FL[Flask IoT Server <br>Porta 5000]:::vm
        SYS[SystemD / Healthcheck]:::vm
        
        NC -.->|Permissões / Pastas| DB
        NC ==>|Evento de Upload <br> via Webhook| FL
        SYS -.->|Monitoramento Liveness| NC
        SYS -.->|Monitoramento Liveness| FL
    end
    
    subgraph "Dispositivo IoT (192.168.10.20)"
        ESP[ESP32 Controlador]:::iot
        CAM((Câmera OV2640)):::iot
        
        ESP --- CAM
        ESP -->|Expõe API HTTP <br>Porta 80| CAM
    end
    
    subgraph "Usuários da Equipe / Família"
        USER1(📱 iPhone/Android <br> via HTML UI):::user
        USER2(💻 PC Windows / MacBook):::user
    end
    
    %% Conexões LAN
    LAN -. "DHCP e Roteamento" .- NC
    LAN -. "DHCP Fixo" .- ESP
    LAN -. "Conexão Wi-Fi" .- USER1
    LAN -. "Conexão Wi-Fi" .- USER2
    
    %% Ação do Usuário
    USER1 ==>|"1. Envio de Arquivos \n(NAS)"| NC
    
    %% Ação IoT
    FL ==>|"2. GET /capture"| ESP
    ESP ==>|"3. Retorna Binário JPG"| FL
    FL -.->|"4. Salva Imagem c/ Overlay"| NC
    
    %% Visualização Logs
    USER2 -->|"Acessa Dashboard"| FL
```

### Explicação do Fluxo Crítico:
1. Um usuário sobe uma Midia no App web do Nextcloud local.
2. O sistema de Webhooks do Nextcloud dispara uma notificação PUSH em formato JSON pro nosso arquivo `server.py` escutando na porta 5000.
3. O Flask solicita ativamente que o ESP tire uma foto enviando um GET `/capture`.
4. O ESP processa, liga a câmera e devolve o byte-stream localmente pro Flask.
5. O Flask injeta Carimbos de Tempo usando o OpenCV e joga o arquivo final de volta pro Nextcloud, listando-o na interface de Dashboard visual.
