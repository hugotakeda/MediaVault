# Guia de Instalação da VM Linux no macOS via UTM

Este guia ensinará como provisionar o seu servidor NAS usando o **UTM** no macOS.

## 1. Baixar os requisitos
1. Baixe e instale o **UTM** (gratuito no site oficial [mac.getutm.app](https://mac.getutm.app/) ou na Mac App Store).
2. Baixe a imagem ISO do **Ubuntu Server 22.04 LTS** (versão ARM64 se seu Mac for M1/M2/M3, ou AMD64 se for Mac Intel).

## 2. Criando a Máquina Virtual no UTM
1. Abra o UTM e clique em **"+" (Create a New Virtual Machine)**.
2. Selecione **Virtualize** (para rodar nativamente) > **Linux**.
3. Em *Boot ISO Image*, clique em **Browse** e selecione a ISO do Ubuntu Server que você baixou.
4. Clique em **Continue**.

## 3. Configuração de Hardware
1. **Memória (RAM):** Aloque pelo menos **4096 MB (4 GB)**.
2. **CPU:** Aloque **2 cores** (ou mais se desejar maior velocidade no processamento de imagens do OpenCV).
3. **Armazenamento (Storage):** Defina o tamanho do disco virtual para **50 GB** (esse espaço será usado para o sistema Linux e armazenamento do NAS).
4. Em *Shared Directory*, pode pular esta etapa (*Continue*).
5. Defina o nome da VM como **NAS_Familiar** e clique em **Save**.

## 4. Configuração de Rede (Modo Bridge)
> **Importante:** Para que o servidor NAS seja visível pelos dispositivos móveis na LAN, precisamos colocar a interface de rede em modo Bridge.
1. Antes de iniciar a VM, clique nela com o botão direito e vá em **Edit**.
2. Vá até a seção **Network** no menu lateral.
3. Altere o *Network Mode* de *Shared Network* para **Bridged (Advanced)**.
4. Em *Bridged Interface*, selecione a interface de rede que estará conectada ao ponto de acesso criado pelo Mac (normalmente o próprio Wi-Fi do Mac ou a interface baseada em como você configurou o Compartilhamento, exemplo `bridge100`).
5. Clique em **Save**.

## 5. Instalação do Ubuntu Server
1. Dê um duplo clique na VM para iniciá-la.
2. Siga as instruções de instalação do Ubuntu:
   - Idioma: **English**
   - Teclado: Escolha o layout adequado.
   - **Network Connections:** Anote a interface de rede (`enp0s2` ou similar). O IP estará como DHCP por enquanto, não tem problema, configuraremos o estático depois.
   - **Storage Configuration:** Use a opção padrão "Use an entire disk" e não configure LVM se quiser simplificar, ou mantenha o LVM padrão. Certifique-se de que a partição raiz (`/`) está usando todo o espaço do VG.
   - **Profile:** 
     - Your name: `Administrador`
     - Server's name: `nasserver`
     - Username: `adminnas`
     - Password: `[SuaSenhaSegura]`
   - **SSH Setup:** Marque a opção **"Install OpenSSH server"** (Crucial para administrarmos o NAS pelo terminal do macOS).
   - **Featured Server Snaps:** Não instale o Nextcloud por aqui agora, faremos a instalação e tunning manualmente para integrá-lo com o Flask e o banco MariaDB.
3. Aguarde a instalação, selecione "Reboot Now" e, quando pedir, pressione ENTER (o UTM ejetará a ISO automaticamente).

Sua VM está pronta! Agora, vá para o próximo guia para colocar o Mac como Roteador.
