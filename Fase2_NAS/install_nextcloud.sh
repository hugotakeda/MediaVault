#!/bin/bash

# ==============================================================================
# Instalação do Nextcloud (LEMP Stack no Ubuntu Server 22.04 LTS)
# Este script instala o Nginx, MariaDB, PHP 8.1, faz o download do Nextcloud,
# cria o banco de dados e executa a instalação silenciosa via CLI (occ).
# ==============================================================================

if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute este script usando sudo."
  exit
fi

echo "[1/4] Instalando Nginx, MariaDB e dependências PHP 8.1..."
apt-get install -y nginx mariadb-server libmagickcore-6.q16-6-extra redis-server
apt-get install -y php-fpm php-mysql php-common php-cli php-gd php-json php-curl \
  php-mbstring php-intl php-imagick php-xml php-zip php-apcu php-bcmath php-gmp php-redis

echo "[2/4] Configurando o Banco de Dados (MariaDB)..."
# Cria o usuário 'nextcloud' com senha 'NasFamiliarDB2026'
mysql -u root -e "CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
mysql -u root -e "CREATE USER IF NOT EXISTS 'nextcloud'@'localhost' IDENTIFIED BY 'NasFamiliarDB2026';"
mysql -u root -e "GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

echo "[3/4] Baixando e Extraindo o Nextcloud..."
cd /tmp
wget https://download.nextcloud.com/server/releases/latest.zip
unzip -q latest.zip
mkdir -p /var/www/nextcloud
cp -R nextcloud/* /var/www/nextcloud/
chown -R www-data:www-data /var/www/nextcloud
chmod -R 755 /var/www/nextcloud

# Configura o diretório real de dados do Nextcloud (criado no setup_inicial.sh)
mkdir -p /mnt/nas_data/nextcloud_data
chown -R www-data:www-data /mnt/nas_data/nextcloud_data
chmod -R 770 /mnt/nas_data/nextcloud_data

echo "[4/4] Executando a Instalação Inicial do Nextcloud via CLI (occ)..."
# Usa o utilitário OCC (OwnCloud Console) para instalar sem precisar clicar na interface web
sudo -u www-data php /var/www/nextcloud/occ maintenance:install \
    --database "mysql" \
    --database-name "nextcloud" \
    --database-user "nextcloud" \
    --database-pass "NasFamiliarDB2026" \
    --admin-user "admin" \
    --admin-pass "AdminNas2026" \
    --data-dir "/mnt/nas_data/nextcloud_data"

# Adicionar domínios confiáveis
sudo -u www-data php /var/www/nextcloud/occ config:system:set trusted_domains 1 --value="192.168.10.10"
sudo -u www-data php /var/www/nextcloud/occ config:system:set trusted_domains 2 --value="nas.local"

# Configurar Nextcloud para usar o APCu e Redis para cache de memória (Otimiza a performance)
sudo -u www-data php /var/www/nextcloud/occ config:system:set memcache.local --value="\OC\Memcache\APCu"
sudo -u www-data php /var/www/nextcloud/occ config:system:set memcache.distributed --value="\OC\Memcache\Redis"
sudo -u www-data php /var/www/nextcloud/occ config:system:set redis host --value="localhost"
sudo -u www-data php /var/www/nextcloud/occ config:system:set redis port --value="6379"

echo "----------------------------------------"
echo "Nextcloud Instalado com Sucesso!"
echo "Login: admin | Senha: AdminNas2026"
echo "Próximo passo: Configurar o Nginx."
echo "----------------------------------------"
