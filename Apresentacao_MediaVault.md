# 📂 MediaVault: Guia Técnico de Defesa e Arquitetura

Este documento fornece um detalhamento profundo sobre o sistema **MediaVault**. Ele foi estruturado para servir de base para uma apresentação de engenharia, abordando desde as barreiras físicas de rede até os protocolos customizados de camada de aplicação.

---

## 1. Visão Geral e Objetivo
O **MediaVault** é uma solução de infraestrutura híbrida que une um **NAS (Network Attached Storage)** privado com um sistema de **Captura IoT Distribuída**.
*   **Objetivo:** Permitir que uploads de arquivos em uma nuvem privada disparem capturas fotográficas automáticas em hardware remoto, superando as restrições de redes móveis e firewalls corporativos.

---

## 2. O Desafio Técnico: A Barreira da Rede Móvel (4G)
O projeto enfrentou três bloqueios críticos de infraestrutura:
1.  **Isolamento de Cliente (AP Isolation):** No modo Hotspot de iPhones/Androids, os dispositivos conectados não podem "falar" entre si. Isso impedia que o servidor Flask (no Mac) enviasse um comando direto para a câmera (ESP32).
2.  **Filtragem de Pacotes (Deep Packet Inspection):** Operadoras de celular cortam conexões HTTP POST que carregam arquivos binários (implantando erros de `connection lost`) para evitar spam e uso excessivo de uplink.
3.  **Limitação de Memória SSL:** O ESP32-CAM possui apenas ~300KB de RAM utilizável. O "handshake" do HTTPS consome quase metade disso, causando travamentos durante a captura de imagens.

---

## 3. A Solução Arquitetural: "Cloud-Bridge Polling" ☁️
Para contornar o isolamento, removemos a dependência de IP local e usamos uma ponte pública:
*   **Cloudflare Tunnels:** A VM (Ubuntu) expõe seu serviço Flask via um túnel criptografado para o endereço `representation-missile-billy-auto.trycloudflare.com`.
*   **Mecanismo de Polling:** A câmera assume um papel ATIVO (client) e "pergunta" ao servidor a cada 3 segundos: *"Tenho trabalho?"*. Isso garante que o tráfego sempre saia da rede local para a pública, bypassando regras de firewall de entrada (Inbound rules).

---

## 4. O Coração do Sistema: Protocolo "Fragmented Hero" 🥋
Este protocolo foi desenvolvido sob medida para garantir a entrega da foto no 4G:
1.  **Base64 Encoding:** A imagem binária (.jpg) é convertida para uma String Base64. Isso transforma a foto em um "texto", que é menos filtrado pelas operadoras.
2.  **Chunking (Fragmentação):** A String é dividida em blocos de **400 caracteres**.
3.  **Injeção via GET e URL Encoding:** Cada pedaço é enviado via método GET. Para garantir segurança, usamos um codificador URL customizado no ESP32 que substitui caracteres especiais (`+`, `/`, `=`) por sequências hexadecimais (ex: `%2B`).
4.  **Janela de Respiro:** Inserimos um `delay(300)` entre os pacotes para não inundar o buffer de upload do rádio 4G, mantendo a conexão estável.
5.  **Reassembly Autônomo:** O servidor Flask coleta os fragmentos usando um `ID` único e o índice da parte (`part`). Assim que todas chegam, ele funde os textos e reconverte para binário, salvando o arquivo final.

---

## 5. Fluxo de Execução (Diagrama de Sequência) 🔄
1.  **Trigger:** O usuário sobe um arquivo no **Nextcloud**.
2.  **Notification:** O **Nextcloud Flow** detecta o evento e dispara um **Webhook (POST)** para `127.0.0.1:5000/upload-event`.
3.  **State Management:** O servidor Flask muda a variável `pending_upload` para `True`.
4.  **Detection:** No próximo ciclo de polling, o ESP32 recebe a resposta `status: trigger`.
5.  **Action:** O ESP32 inicializa o sensor OV2640, tira a foto (resolução QQVGA para máxima estabilidade) e inicia a fragmentação.
6.  **Confirmation:** O servidor confirma o recebimento do último pedaço e atualiza a **Dashboard em tempo real** via Polling do Navegador.

---

## 6. Stack Tecnológica Detalhada
*   **Virtualização:** UTM (QEMU/Apple Silicon) com Ubuntu Server 22.04.
*   **Serviços de Nuvem:** Nextcloud (PHP/Nginx/MariaDB).
*   **Middleware:** Python 3 + Flask (Gerenciamento de State e Fragmentos).
*   **Hardware:** ESP32 TTGO T-Camera Plus (C++ Arduino).
*   **Frontend:** Dashboard Assíncrona (HTML5/Vanilla JS).
*   **Conectividade:** Cloudflare Cloudflared (Tunneling).

---

## 7. Dados de Performance e Otimização
*   **Tamanho do Fragmento:** 400 bytes (Ideal para bypass de pacotes MTU baixos).
*   **Resolução:** 160x120 (QQVGA) - Equilíbrio entre visualização e velocidade de upload.
*   **Segurança:** Acesso via Zero Trust Cloudflare.

---
**Orientação para Demonstração:**
Explique que o sistema foi projetado para ser "Resiliente a Falhas". Se uma parte da foto falhar, o protocolo GET permite o reenvio simplificado, e a técnica de fragmentação garante que mesmo um sinal de celular muito fraco consiga concluir o upload da foto completa.

**MediaVault: Engenharia de Protocolos para Internet das Coisas.** 🚀📸🏆
