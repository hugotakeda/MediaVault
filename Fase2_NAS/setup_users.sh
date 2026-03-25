#!/bin/bash
# ==============================================================================
# Criação de Usuários e Pastas do Projeto NAS Familiar
# Utiliza o comando nativo do Nextcloud (occ) para criar regras de controle.
# ==============================================================================

if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute como root."
  exit
fi

cd /var/www/nextcloud

echo "[1/4] Instalando a extensão Group Folders..."
sudo -u www-data php occ app:install groupfolders

echo "[2/4] Criando Grupos Semânticos da Família..."
sudo -u www-data php occ group:add Administrador
sudo -u www-data php occ group:add Adultos
sudo -u www-data php occ group:add Criancas

# Adiciona o admin default ao grupo Administrador
sudo -u www-data php occ group:adduser Administrador admin

echo "[3/4] Criando Usuários Familiares..."
# 3 Adultos (Possuem permissão de Upload e Visualização)
sudo -u www-data sh -c 'OC_PASS="FamiliaNas2026" php occ user:add Joao --password-from-env --group="Adultos"'
sudo -u www-data sh -c 'OC_PASS="FamiliaNas2026" php occ user:add Maria --password-from-env --group="Adultos"'
sudo -u www-data sh -c 'OC_PASS="FamiliaNas2026" php occ user:add Carlos --password-from-env --group="Adultos"'

# 2 Crianças (Permissão apenas de Leitura nas mídias familiares)
sudo -u www-data sh -c 'OC_PASS="CriancaNas2026" php occ user:add Pedrinho --password-from-env --group="Criancas"'
sudo -u www-data sh -c 'OC_PASS="CriancaNas2026" php occ user:add Aninha --password-from-env --group="Criancas"'

echo "[4/4] Criando Pastas Compartilhadas da Família e setando ACLs..."
sudo -u www-data php occ groupfolders:create Familia_Fotos
sudo -u www-data php occ groupfolders:create Familia_Videos
sudo -u www-data php occ groupfolders:create Familia_Documentos
sudo -u www-data php occ groupfolders:create Logs_IoT

# Setando permissões para a pasta Familia_Fotos (Group folder ID 1)
sudo -u www-data php occ groupfolders:group 1 Administrador write
sudo -u www-data php occ groupfolders:group 1 Adultos write
sudo -u www-data php occ groupfolders:group 1 Criancas read

# Setando permissões para a pasta Familia_Videos (Group folder ID 2)
sudo -u www-data php occ groupfolders:group 2 Administrador write
sudo -u www-data php occ groupfolders:group 2 Adultos write
sudo -u www-data php occ groupfolders:group 2 Criancas read

# Setando permissões para a pasta Familia_Documentos (Group folder ID 3)
sudo -u www-data php occ groupfolders:group 3 Administrador write
sudo -u www-data php occ groupfolders:group 3 Adultos write
sudo -u www-data php occ groupfolders:group 3 Criancas read

# Setando permissões para a pasta Logs_IoT (Group folder ID 4) (Acesso Restrito ao Admin)
# Somente o Administrador precisa acessar/ver as fotos capturadas pelas câmeras de segurança/registros
sudo -u www-data php occ groupfolders:group 4 Administrador write

# Ocupando permissões de quotas padrão
sudo -u www-data php occ user:setting admin files quota "10 GB"
sudo -u www-data php occ user:setting Joao files quota "5 GB"

echo "----------------------------------------"
echo "Todos os usuários, grupos e pastas compartilhadas foram criados com sucesso!"
echo "----------------------------------------"
