# Tabela de Rede — Endereçamento e Portas

Este documento lista estaticamente o alocamento escolhido para a infraestrutura do projeto. Todo o funcionamento considera a LAN offline (`Rede_IoT_NAS`).

## Subnet Base
- **Rede Wi-Fi:** `Rede_IoT_NAS`
- **Senha:** `NasFamiliar2026`
- **Gateway (MacBook):** `192.168.10.1`
- **Máscara:** `255.255.255.0` (CIDR /24)

## Endereços Fixados

| Dispositivo / Serviço | IP Atribuído | Porta | Uso Principal / Papel |
|-----------------------|--------------|-------|------------------------|
| **MacBook (Host)** | `192.168.10.1` | - | Access Point (Roteador), Gateway L2 |
| **Servidor NAS (VM)** | `192.168.10.10` | - | IP base virtual configurado via Netplan |
| Servidor Nginx/App | Local | `80` (HTTP)| Interface web principal (`nas.local`), Painel de Arquivos |
| Servidor Nginx/App SSL | Local | `443`(HTTPS)| Interface web segura (Autoassinado) |
| Servidor Flask (IoT) | Local | `5000` | Escuta webhooks locais e provê a Dashboard HTML |
| Banco de Dados MariaDB | Local | `3306` | Acesso interno (socket/localhost) pelo Nextcloud |
| Acesso Administrativo | Local | `22` (SSH)| Terminal para administração remota via Mac (`ssh adminnas@...`) |
| **Câmera ESP32** | `192.168.10.20` | `80` | Endpoint de captura `/capture` e WebServer nativo do Arduino |

## Usuários de Sistema e Bancos

| Recurso | Credenciais Propostas |
|---------|-----------------------|
| Usuário Root da VM | `adminnas` / `[SenhaSegura]` |
| Root do MariaDB | `root` / Sem senha no Debian socket-auth |
| Usuário MariaDB Nextcloud | `nextcloud` / `NasFamiliarDB2026` |
| Painel Nextcloud (Admin) | `admin` / `AdminNas2026` |
