# Configuração do Ponto de Acesso Wi-Fi no macOS (Rede LAN LAN Privada)

Para termos uma LAN isolada da rede da faculdade, o seu MacBook funcionará como um roteador usando o recurso nativo de "Compartilhamento de Internet" (Internet Sharing) do macOS.

## Pré-requisitos
Como o Mac vai transmitir o Wi-Fi, ele precisa *receber* a internet de outra fonte se você quiser que o servidor NAS tenha acesso à web para atualizações (embora o acesso externo para uso do NAS não seja necessário).
- **Opção A:** O Mac recebe internet via cabo (Ethernet/Adaptador) e compartilha via **Wi-Fi**.
- **Opção B:** Se o Mac não tiver internet via cabo, ele recria a LAN Wi-Fi para os dispositivos apenas localmente (sem internet externa, ou usando o Wi-Fi para conectar no celular via cabo USB e retransmitindo via Wi-Fi do Mac).

## Passo a Passo no macOS (Ventura / Sonoma / Sequoia):

1. Clique na **Maçã (Apple) > Ajustes do Sistema... (System Settings)**.
2. Na barra lateral, clique em **Geral (General) > Compartilhamento (Sharing)**.
3. Encontre a opção **Compartilhamento de Internet (Internet Sharing)** na lista (não ative a chave principal ainda). Clique no ícone de "i" ao lado.
4. Configure assim:
   - **Compartilhar a conexão de (Share your connection from):** Selecione a fonte da internet (ex: Ethernet, ou iPhone USB). Se quiser um ambiente 100% sem internet, você pode selecionar uma interface ociosa.
   - **Para os computadores usando (To computers using):** Marque a caixinha **Wi-Fi**.
5. Clique no botão inferior **Opções de Wi-Fi... (Wi-Fi Options...)**.
6. Preencha os dados da sua nova rede LAN isolada:
   - **Nome da Rede (Network Name):** `Rede_IoT_NAS`
   - **Canal (Channel):** O padrão (11) está ótimo.
   - **Segurança (Security):** WPA2/WPA3 Personal.
   - **Senha (Password):** `NasFamiliar2026` (ou a senha que desejar).
   - Clique em **OK**.
7. Agora, ative a chave principal do **Compartilhamento de Internet**. O macOS pedirá uma confirmação, clique em **Iniciar (Start)**.

## Verificando a Rede
Neste momento, o MacBook criou a rede `Rede_IoT_NAS` e atua como Servidor DHCP nativo do macOS, geralmente na faixa IP `192.168.2.x` ou `192.168.100.x` através de uma interface de ponte virtual (geralmente `bridge100`).

Para confirmar a faixa de IP criada pelo Mac, abra o **Terminal** no Mac e digite:
```bash
ifconfig bridge100 | grep inet
```
Isso mostrará o IP do roteador (seu Mac) na nova rede. Por exemplo: `inet 192.168.100.1`.

> **Nota para o Projeto:** Se a sua rede local gerada pelo Mac for `192.168.100.0/24`, o servidor NAS receberá um IP nessa faixa (ex: `192.168.100.10`) no arquivo de configuração do Netplan.
