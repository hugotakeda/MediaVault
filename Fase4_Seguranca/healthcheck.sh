#!/bin/bash
# ==============================================================================
# Script de Healthcheck do Servidor NAS Familiar
# Verifica se os pilares (Nginx, MariaDB, Flask Server) estão rodando normalmente.
# Ideal para ser agendado no crontab (`*/5 * * * * /caminho/healthcheck.sh`)
# ==============================================================================

LOG_FILE="/var/log/nas_familiar/healthcheck.log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

# Função de alerta no terminal se rodado manualmente
log_msg() {
    echo "[$DATE] $1"
    echo "[$DATE] $1" >> $LOG_FILE
}

log_msg "Iniciando verificação de Healthcheck do NAS..."

# 1. Verifica Nextcloud Web (Nginx)
if systemctl is-active --quiet nginx; then
    log_msg "[OK] Nginx (Web Server) está rodando."
else
    log_msg "[ERRO/CRÍTICO] Nginx não está rodando. Tentando reiniciar..."
    systemctl restart nginx
fi

# 2. Verifica Banco de Dados (MariaDB)
if systemctl is-active --quiet mariadb; then
    log_msg "[OK] MariaDB (Database) está rodando."
else
    log_msg "[ERRO/CRÍTICO] MariaDB está fora do ar. Reiniciando..."
    systemctl restart mariadb
fi

# 3. Verifica Monitor de Eventos IoT (Flask Server)
if systemctl is-active --quiet flask-iot.service; then
    log_msg "[OK] Servidor Flask IoT está operando e escutando webhooks."
else
    log_msg "[AVISO] Servidor Flask IoT está offline. Tentando inicializar..."
    systemctl restart flask-iot.service
fi

# 4. Verifica Espaço em Disco
DISK_USAGE=$(df /mnt/nas_data | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 85 ]; then
    log_msg "[ALERTA] Espaço em disco Crítico no diretório /mnt/nas_data. Usado: ${DISK_USAGE}%"
else
    log_msg "[OK] Espaço em disco estável: ${DISK_USAGE}% usado."
fi

log_msg "Verificação concluída."
echo "---------------------------------------------------------" >> $LOG_FILE
