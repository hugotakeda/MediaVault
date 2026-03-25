#!/bin/bash
# ==============================================================================
# Configuração de Serviços do SystemD para Alta Disponibilidade
# Cria units systemd críticos: O Cron do Nextcloud e o Servidor Flask IoT.
# ==============================================================================

if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute este script usando sudo."
  exit
fi

echo "[1/2] Configurando serviço Cron periódico do Nextcloud..."
# O Nextcloud pede execução de CRON de 5 em 5 minutos
cat << 'EOF' > /etc/systemd/system/nextcloudcron.service
[Unit]
Description=Nextcloud cron.php job

[Service]
User=www-data
ExecStart=/usr/bin/php -f /var/www/nextcloud/cron.php
KillMode=process
EOF

cat << 'EOF' > /etc/systemd/system/nextcloudcron.timer
[Unit]
Description=Run Nextcloud cron.php every 5 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=5min
Unit=nextcloudcron.service

[Install]
WantedBy=timers.target
EOF

systemctl enable --now nextcloudcron.timer

echo "[2/2] Configurando Serviço para o Servidor Flask (Integração IoT) da Fase 3..."
cat << 'EOF' > /etc/systemd/system/flask-iot.service
[Unit]
Description=Servidor Flask IoT (Ponte Nextcloud <-> ESP32)
After=network.target

[Service]
User=root
# O Flask será colocado nesse diretório na Fase 3
WorkingDirectory=/home/nasadmin/Fase3_IoT
ExecStart=/usr/bin/python3 /home/nasadmin/Fase3_IoT/server.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Habilitando Nginx e MariaDB para iniciar no boot
systemctl enable nginx
systemctl enable mariadb

systemctl enable flask-iot.service
systemctl daemon-reload

echo "Serviços carregados com sucesso. O Flask IoT (Fase 3) falhará ao iniciar agora pois ainda criaremos os arquivos, mas a configuração SystemD já está pronta para quando ele ligar!"
