#!/bin/bash

# Cores (Mantendo o padrão do projeto)
AZUL='\033[0;34m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
RESET='\033[0m'

echo -e "${AZUL}======================================================${RESET}"
echo -e "${VERDE}           INSTALADOR ZED EDITOR (GERAL)             ${RESET}"
echo -e "${AZUL}======================================================${RESET}"

# 1. Verificar Pré-requisitos
echo -e "${AMARELO}🔍 Verificando dependências...${RESET}"
sudo apt update && sudo apt install -y curl tar xz-utils unzip

# 2. Instalar Zed via Script Oficial
if command -v zed &> /dev/null; then
    echo -e "${VERDE}✅ Zed já está instalado no sistema.${RESET}"
else
    echo -e "${AMARELO}📥 Descarregando e instalando Zed...${RESET}"
    curl -f https://zed.dev/install.sh | sh

    # Garantir que ~/.local/bin está no PATH para esta sessão e futuras
    if [[ ! "$PATH" == *"$HOME/.local/bin"* ]]; then
        echo -e "${AMARELO}⚙️ Adicionando ~/.local/bin ao PATH no .bashrc...${RESET}"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        export PATH="$HOME/.local/bin:$PATH"
    fi
fi

# 3. Configurar Settings (Templates integrados)
echo -e "${AMARELO}🛠️ Aplicando configurações personalizadas...${RESET}"
ZED_CONFIG_DIR="$HOME/.config/zed"
mkdir -p "$ZED_CONFIG_DIR"

# Criando o settings.json (JetBrains Mono + Sem Telemetria)
cat <<EOF > "$ZED_CONFIG_DIR/settings.json"
{
  "theme": "One Dark",
  "ui_font_family": "JetBrains Mono",
  "buffer_font_family": "JetBrains Mono",
  "buffer_font_size": 14,
  "autosave": "on_focus_change",
  "tab_size": 4,
  "hard_tabs": false,
  "soft_wrap": "editor_width",
  "preferred_line_length": 120,
  "format_on_save": "on",
  "telemetry": {
    "diagnostics": false,
    "metrics": false
  },
  "vim_mode": false,
  "languages": {
    "PHP": {
      "language_servers": ["phpactor", "intelephense"],
      "format_on_save": "on"
    }
  }
}
EOF

echo -e "${VERDE}✅ Zed Editor configurado com sucesso!${RESET}"
