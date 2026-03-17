#!/bin/bash

# Cores (Padrão do Projeto)
AZUL='\033[0;34m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
RESET='\033[0m'

echo -e "${AZUL}======================================================${RESET}"
echo -e "${VERDE}       VSCodium Gemini Code Assist Edition          ${RESET}"
echo -e "${AZUL}======================================================${RESET}"

# 1. Verificar Pré-requisitos
echo -e "${AMARELO}🔍 Verificando dependências...${RESET}"
sudo apt update && sudo apt install -y wget curl gpg unzip

# 2. Instalar VSCodium via Repositório Oficial
if ! command -v codium &> /dev/null; then
    echo -e "${AMARELO}📥 Adicionando repositório e instalando VSCodium...${RESET}"
    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
        | gpg --dearmor \
        | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg status=none

    echo 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' \
        | sudo tee /etc/apt/sources.list.d/vscodium.sources > /dev/null

    sudo apt update && sudo apt install codium -y
else
    echo -e "${VERDE}✅ VSCodium já está instalado.${RESET}"
fi

# 3. Instalar Extensões (Foco Gemini + Moodle/Docker)
echo -e "${AMARELO}🧩 Instalando extensões selecionadas...${RESET}"
extensions=(
      # Desenvolvimento PHP/Moodle
      "google.gemini-code-assist"
      "bmewburn.vscode-intelephense-client"
      "mehedi-hassan.php-namespace-resolver"
      "imgildev.vscode-moodle-snippets"
      "fischerman.mdlcode"
      "junstyle.php-cs-fixer"
      "terryfly.vscode-mustache"

      # Docker & Remote (Essencial para sua nova stack)
      "ms-azuretools.vscode-docker"
      "ms-vscode-remote.remote-containers"

      # Interface & Produtividade
      "k--kato.intellij-idea-keybindings"
      "mrmlnc.vscode-scss"
      "redhat.vscode-xml"
      "formulahendry.auto-close-tag"
      "formulahendry.auto-rename-tag"
      "mtxr.sqltools"
      "mtxr.sqltools-driver-mysql"
      "narasimapandiyan.jetbrainsmono"
      "fogio.jetbrains-color-theme"
      "fogio.jetbrains-file-icon-theme"
)

for ext in "${extensions[@]}"; do
    echo -e "   -> Instalando $ext..."
    codium --force --install-extension "$ext" &>/dev/null
done

# 4. Aplicar Configurações (settings.json)
echo -e "${AMARELO}⚙️ Aplicando configurações de interface...${RESET}"
CONFIG_DIR="$HOME/.config/VSCodium/User"
mkdir -p "$CONFIG_DIR"

cat <<EOF > "$CONFIG_DIR/settings.json"
{
    "telemetry.enableTelemetry": false,
    "telemetry.enableCrashReporter": false,
    "workbench.colorTheme": "JetBrains New UI Extended",
    "workbench.iconTheme": "jetbrains-file-icons-extended",
    "editor.fontFamily": "'JetBrains Mono', 'Fira Code', monospace",
    "editor.fontLigatures": true,
    "editor.fontSize": 14,
    "editor.lineHeight": 1.6,
    "editor.guides.bracketPairs": "active",
    "files.autoSave": "onFocusChange",
    "workbench.editor.enablePreview": false,
    "explorer.compactFolders": false,
    "workbench.tree.indent": 20,
    "editor.formatOnSave": true,
    "[php]": {
        "editor.defaultFormatter": "junstyle.php-cs-fixer"
    },
    "php.suggest.basic": false,
    "intelephense.completion.triggerParameterHints": true,
    "terminal.integrated.copyOnSelection": true,
    "workbench.startupEditor": "none",
    "docker.commands.build": "docker build",
    "docker.commands.run": "docker run",
    "docker.commands.composeUp": "docker-compose up -d",
    "editor.minimap.enabled": false
}
EOF

echo -e "${VERDE}✅ VSCodium configurado para Gemini com sucesso!${RESET}"
