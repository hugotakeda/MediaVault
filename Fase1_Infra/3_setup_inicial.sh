#!/bin/bash

# ==============================================================================
# Script de Configuração Inicial do Servidor NAS (Ubuntu Server 22.04 LTS)
# Este script prepara o SO instalando pacotes base e definindo segurança inicial.
#
# COMO USAR:
# 1. Envie para a VM: scp setup_inicial.sh adminnas@<IP_DA_VM>:/home/adminnas/
# 2. Na VM, dê permissão: chmod +x setup_inicial.sh
# 3. Execute como root: sudo ./setup_inicial.sh
# ==============================================================================

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute este script usando sudo."
  exit
fi

echo "========================================"
echo " Iniciando Setup Inicial do Servidor NAS"
echo "========================================"

# 1. Atualização do Sistema
echo "[1/6] Atualizando os pacotes do sistema (apt update & upgrade)..."
apt-get update -y
apt-get upgrade -y
apt-get autoremove -y

# 2. Instalação de Ferramentas Essenciais
echo "[2/6] Instalando utilitários essenciais (curl, wget, htop, git, python3)..."
apt-get install -y curl wget htop git unzip vim net-tools software-properties-common python3 python3-pip python3-venv

# 3. Configuração de Timezone (Fuso Horário)
echo "[3/6] Configurando o fuso horário para America/Sao_Paulo..."
timedatectl set-timezone America/Sao_Paulo

# 4. Criação e Configuração dos Diretórios Base do Projeto
echo "[4/6] Criando diretórios para o armazenamento de mídias e logs IOT..."
# O Nextcloud usará o diretório /mnt/nas_data para os dados principais
mkdir -p /mnt/nas_data/Logs_IoT
mkdir -p /mnt/nas_data/Fotos
mkdir -p /mnt/nas_data/Videos
mkdir -p /mnt/nas_data/Documentos

# Cria diretório de logs nativos do sistema
mkdir -p /var/log/nas_familiar
touch /var/log/nas_familiar/system.log

# Ajusta permissões básicas (serão repassadas ao www-data posteriormente no script do Nextcloud)
chown -R www-data:www-data /mnt/nas_data
chmod -R 775 /mnt/nas_data
chown -R root:root /var/log/nas_familiar

# 5. Configuração Básica do Firewall (UFW)
echo "[5/6] Configurando regras de Firewall local (UFW)..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh         # Permite acesso via SSH
ufw allow http        # Permite acesso ao Nginx (Porta 80)
ufw allow https       # Permite acesso ao Nginx (Porta 443)
ufw allow 5000/tcp    # Endpoint do Flask que receberá os arquivos do ESP32
# Ativa o firewall sem confirmação interativa
echo "y" | ufw enable

# 6. Sumário e Fim
echo "[6/6] Configuração inicial concluída com sucesso!"
echo "----------------------------------------"
echo "O sistema base está pronto."
echo "Próximo passo: Configurar a placa de rede no Netplan."
echo "----------------------------------------"

exit 0
