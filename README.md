# 🎥 MediaVault — NAS Familiar & IoT Integration

![Status](https://img.shields.io/badge/Status-Produção-success)
![Hardware](https://img.shields.io/badge/Hardware-ESP32--CAM-blue)
![Service](https://img.shields.io/badge/Service-Nextcloud-blueviolet)

O **MediaVault** é um ecossistema completo de Nuvem Privada (NAS) integrado a um sistema inteligente de captura fotográfica IoT. O projeto permite que fotos sejam disparadas automaticamente por eventos de upload no Nextcloud ou via disparo manual por uma Dashboard responsiva, funcionando de forma resiliente mesmo em redes móveis (4G) instáveis.

## 🚀 Principais Tecnologias
- **Nextcloud Hub:** Nuvem privada com gestão de usuários e grupos (ACL).
- **Python Flask:** Backend de orquestração IoT e Dashboard em tempo real.
- **ESP32-CAM (TTGO):** Hardware de captura com o protocolo exclusivo **Fragmented Hero**.
- **Cloudflare Tunnels:** Acesso externo seguro sem necessidade de abertura de portas (Zero Trust).

## 🛠 Arquitetura do Sistema
O projeto está dividido em 5 fases de implementação:
- **Fase 1 (Infra):** Configuração da VM Ubuntu e rede.
- **Fase 2 (NAS):** Instalação e configuração do Nextcloud.
- **Fase 3 (IoT):** Servidor de polling, dashboard e firmware da câmera.
- **Fase 4 (Segurança):** Testes de estresse e validação ponta-a-ponta.
- **Fase 5 (Docs):** Manuais de usuário e tabelas de portas.

### 🛡 Protocolo Fragmented Hero
Para vencer a instabilidade de redes 4G e bloqueios de operadoras, implementamos uma técnica de **Fragmentação de Dados**:
1. A câmera captura a foto e converte para **Base64**.
2. O payload é dividido em pedaços de **400 bytes**.
3. Cada pedaço é enviado via **GET Requests** camuflados como tráfego comum.
4. O servidor Flask reativa a imagem original após receber todas as partes.

## 📦 Como Instalar
1. **VM Ubuntu:** Siga os scripts em `Fase1_Infra` para preparar o ambiente.
2. **Nextcloud:** Execute `Fase2_NAS/install_nextcloud.sh`.
3. **Servidor IoT:** Configure o `Fase3_IoT/server.py` como um serviço do Systemd.
4. **Firmware:** Carregue o arquivo `.ino` em `Fase3_IoT/esp32_camera/` para o seu ESP32.

## 📈 Dashboard IoT
O sistema inclui uma Dashboard moderna (Dark Mode) para monitoramento em tempo real das capturas, integrada com o sistema de arquivos do NAS.

---
Desenvolvido como projeto final de **Infraestrutura e IoT**. 📸🏆
