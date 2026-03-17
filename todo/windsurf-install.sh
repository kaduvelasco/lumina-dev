#!/bin/bash

# Cores para feedback
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Windsurf AI Moodle Professional (Storm Edition v2.1) ===${NC}\n"

# 1. Verificar Pré-requisitos
check_dependencies() {
    echo -e "${YELLOW}Verificando dependências de sistema...${NC}"
    sudo apt update
    sudo apt install -y wget gpg apt-transport-https unzip curl
    echo -e "${GREEN}✅ Pré-requisitos verificados!${NC}"
}

# 2. Instalar Windsurf
install_windsurf() {
    if command -v windsurf &> /dev/null; then
        echo -e "${GREEN}Windsurf já está instalado!${NC}"
        return
    fi

    echo -e "${YELLOW}Configurando repositório e instalando Windsurf...${NC}"
    wget -qO- "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" | gpg --dearmor > windsurf-stable.gpg
    sudo install -D -o root -g root -m 644 windsurf-stable.gpg /etc/apt/keyrings/windsurf-stable.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/windsurf-stable.gpg] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" | sudo tee /etc/apt/sources.list.d/windsurf.list > /dev/null
    rm -f windsurf-stable.gpg
    sudo apt update && sudo apt install windsurf -y
    echo -e "${GREEN}✅ Windsurf instalado com sucesso!${NC}"
}

# 3. Instalar Extensões (Moodle Core + Docker Support)
install_extensions() {
    if ! command -v windsurf &> /dev/null; then
        echo -e "${RED}Erro: Windsurf não encontrado.${NC}"
        return
    fi

    echo -e "${YELLOW}Instalando Extensões (Moodle + Docker + Interface)...${NC}"
    extensions=(
        "bmewburn.vscode-intelephense-client"
        "mehedi-hassan.php-namespace-resolver"
        "imgildev.vscode-moodle-snippets"
        "fischerman.mdlcode"
        "junstyle.php-cs-fixer"
        "terryfly.vscode-mustache"
        "ms-azuretools.vscode-docker" # Essencial para sua nova stack
        "ms-vscode-remote.remote-containers" # Essencial para sua nova stack
        "k--kato.intellij-idea-keybindings"
        "mrmlnc.vscode-scss"
        "redhat.vscode-xml"
        "mtxr.sqltools"
        "mtxr.sqltools-driver-mysql"
        "narasimapandiyan.jetbrainsmono"
        "fogio.jetbrains-color-theme"
        "fogio.jetbrains-file-icon-theme"
    )

    for ext in "${extensions[@]}"; do
        echo "Instalando: $ext"
        windsurf --install-extension "$ext" --force &>/dev/null
    done
    echo -e "${GREEN}✅ Extensões instaladas!${NC}"
}

# 4. Aplicar Configurações
apply_settings() {
    echo -e "${YELLOW}Aplicando Configurações (Estilo Storm / Docker Ready)...${NC}"
    CONFIG_DIR="$HOME/.config/Windsurf/User"
    mkdir -p "$CONFIG_DIR"

    # Backup
    [ -f "$CONFIG_DIR/settings.json" ] && cp "$CONFIG_DIR/settings.json" "$CONFIG_DIR/settings.json.bkp_$(date +%F)"

    cat <<EOF > "$CONFIG_DIR/settings.json"
{
    "workbench.colorTheme": "JetBrains New UI Extended",
    "workbench.iconTheme": "jetbrains-file-icons-extended",
    "editor.fontFamily": "'JetBrains Mono', 'Fira Code', monospace",
    "editor.fontLigatures": true,
    "editor.fontSize": 14,
    "editor.lineHeight": 1.6,
    "editor.guides.bracketPairs": "active",
    "editor.indentSize": "tab",
    "files.autoSave": "onFocusChange",
    "workbench.editor.enablePreview": false,
    "explorer.compactFolders": false,
    "editor.minimap.enabled": false,
    "windsurf.experimental.featureEnabled": true,
    "editor.formatOnSave": true,
    "[php]": {
        "editor.defaultFormatter": "junstyle.php-cs-fixer"
    },
    "php.suggest.basic": false,
    "intelephense.completion.triggerParameterHints": true,
    "terminal.integrated.copyOnSelection": true,
    "workbench.startupEditor": "none"
}
EOF
    echo -e "${GREEN}✅ Configurações aplicadas!${NC}"
}

# 5. Criar Contexto Moodle (O seu diferencial!)
create_moodle_context() {
    echo -e "${BLUE}--- Configuração de Contexto Moodle para IA ---${NC}"
    read -p "Caminho da pasta do seu projeto Moodle: " PROJECT_PATH
    PROJECT_PATH="${PROJECT_PATH/#\~/$HOME}"

    if [ ! -d "$PROJECT_PATH" ]; then
        echo -e "${RED}Erro: Pasta não encontrada.${NC}"; return
    fi

    read -p "Versão do Moodle (ex: 4.5): " MOODLE_VERSION

    cat <<EOF > "$PROJECT_PATH/.windsurfcontext"
# Moodle $MOODLE_VERSION Development Context
- Follow Moodle Coding Style (PSR-12 base).
- Use \$DB global for database. Always use curly braces for tables {table_name}.
- Use optional_param() and required_param() for security.
- Prefer Moodle APIs over native PHP.
- Language strings in lang/en/.

# Exclusions
.git, .github, .idea, .vscode, .vscodium, node_modules, vendor, moodledata, *.zip, *.tar.gz
EOF
    echo -e "${GREEN}✅ Contexto criado em: $PROJECT_PATH${NC}"
}

# Interface do Menu
while true; do
    echo -e "\n${BLUE}--- Menu Windsurf AI (Moodle Storm Edition) ---${NC}"
    echo "1. Instalação Completa (Instalar + Extensões + Temas)"
    echo "2. Apenas Instalar Windsurf"
    echo "3. Apenas Extensões e Temas"
    echo "4. Criar Contexto Moodle (.windsurfcontext)"
    echo "5. Desinstalar Windsurf (Limpeza Profunda)"
    echo "0. Sair"
    read -p "Escolha uma opção: " opt

    case $opt in
        1) check_dependencies; install_windsurf; install_extensions; apply_settings ;;
        2) install_windsurf ;;
        3) install_extensions; apply_settings ;;
        4) create_moodle_context ;;
        5)
            sudo apt remove --purge windsurf -y && sudo apt autoremove -y
            sudo rm -f /etc/apt/sources.list.d/windsurf.list /etc/apt/keyrings/windsurf-stable.gpg
            rm -rf "$HOME/.windsurf" "$HOME/.config/Windsurf"
            ;;
        0) exit 0 ;;
        *) echo -e "${RED}Opção inválida.${NC}" ;;
    esac
done
