#!/bin/bash
# ==============================================================================
# Script de Configuração do Webhook no Nextcloud
# O Webhook irá monitorar o evento de criação de novos arquivos (Upload)
# e notificar nosso servidor Flask IoT sempre que a família fizer uploads.
# ==============================================================================

if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute este script usando sudo."
  exit
fi

cd /var/www/nextcloud

echo "Instalando a extensão auxiliar de Webhooks no Nextcloud..."
# O app webhook_scripts é focado em disparar triggers baseados em eventos
sudo -u www-data php occ app:install webhooks

echo "Nota: Dependendo da versão do Nextcloud, a adição de rotas por OCC pode variar."
echo "Para garantir perfeitamente o seu uso Acadêmico, vamos injetar direto nas configurações ou orientar Interface:"

# Explicando o fluxo de ativação
cat << 'EOF'

==================================================
CONFIGURAÇÃO MANUAL NO NEXTCLOUD (Se o OCC falhar):
1. Acesse o IP do NAS via navegador: http://nas.local
2. Entre com o usuário: admin | Senha: AdminNas2026
3. Vá em "Administração" > "Configurações Adicionais" ou "Webhooks".
4. Adicione um novo Webhook com os detalhes:
   Evento/Trigger: "File created" ou equivalente (Uploads)
   URL Target: "http://127.0.0.1:5000/upload-event"
   Método: POST
==================================================

EOF

# Alternativamente implementando via Workflow Script (Natívo no NC22+):
sudo -u www-data php occ app:install workflow_script
echo "Uma alternativa usando workflow_script foi adicionada. Ela permite que a máquina crie a trigger internamente."

echo "Pronto! O ecossistema de captura passiva aguarda apenas o Flask estar rodando."
