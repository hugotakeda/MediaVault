# Guia de Teste Ponta a Ponta (Demonstração do Sistema)

Este roteiro detalha como comprovar aos professores e à família que o sistema NAS e IoT estão rodando integrados sem depender da rede da faculdade ou internet.

## Pré-Requisitos ⚠️
1. O MacBook deve estar ligado, emitindo o Wi-Fi `Rede_IoT_NAS` (Configurado na Fase 1).
2. A VM UTM (`nas.local` - IP `192.168.10.10`) rodando as aplicações e escutando as requisições.
3. ESP32 ligado na fonte/USB conectado ao mesmo Wi-Fi `Rede_IoT_NAS` (com o IP `192.168.10.20`).
4. Os Serviços *Flask IoT* e *Nextcloud/Nginx* rodando sem alertas no script de Healthcheck.

---

## 📱 Fluxo 1 — Upload via Celular Android
1. No seu celular Android, vá nas Configurações de Wi-Fi e conecte na `Rede_IoT_NAS`.
2. Abra o Google Chrome.
3. Digite `http://192.168.10.10` (ou `http://nas.local`).
4. A tela de Login do Nextcloud aparecerá (Muito Rápido < 3s, graças ao Redis).
5. Entre como **João** e senha **FamiliaNas2026**.
6. Vá na pasta compartilhada "Familia_Fotos" ou "Familia_Videos".
7. Clique no botão de `+` (Novo Upload). Envie alguma foto grande ou vídeo de teste.
8. **Efeito Imediato:** Assim que o progresso bater 100%, a câmera do ESP32 (que está mirada para a mesa) irá disparar (verifique o LED se ativo).

---

## 🍏 Fluxo 2 — Upload via Celular iPhone
1. Conecte o iPhone na `Rede_IoT_NAS`.
2. Abra o aplicativo Safari.
3. Acesse `http://192.168.10.10`.
4. Entre como **Maria** e senha **FamiliaNas2026**.
5. Clique em `+` (Novo Upload) e envie uma foto tirada na hora.
6. A câmera do ESP32 irá ativar novamente, tirando a foto do dono do iPhone e enviando para o Servidor NAS Flask.

---

## 💻 Fluxo 3 — Monitoramento pelo Pai/Administrador (PC/Navegador/MacBook)
1. No seu próprio MacBook Host (onde a VM está) abra o navegador Chrome ou Safari.
2. Como você é o Host com a Bridge virtual da rede, o acesso será instantâneo.
3. Em uma aba, acesse **`http://192.168.10.10:5000`** (Nossa Dashboard em Flask para a fase IoT).
4. Aqui você verá uma lista de "Cards" belíssima contendo a miniatura de quem fez o quê:
   - *Foto Capturada da sala do João com data*
   - *Aviso de qual arquivo (Vídeo e Foto das chamadas 1 e 2) foi enviado*.
5. (Opcional - Arquitetura Fechada): Acesse **`http://192.168.10.10`** e faça Login como **admin**. Vá na pasta Restrita (Group Folder) "Logs_IoT" e visualize os originais completos e pesados salvos pela Câmera e processados pelo SDK OpenCv!

---

> 🎉 **Fim da Demonstração!** Tudo funcionará de forma orquestrada sem pacotes internet saindo da agulha local, perfeitamente em 1 LAN particular e demonstrando conhecimento extensivo de Infra e Eventos (Webhooks).
