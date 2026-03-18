#!/bin/bash

# =============================================================================
# vscode-install.sh — Instalação e configuração do VS Code (Claude Edition)
#
# DESCRIÇÃO   : Instala o VS Code via repositório oficial da Microsoft, aplica
#               extensões focadas em Claude + PHP/Moodle/Docker e configura a
#               interface com ergonomia JetBrains.
# DISTROS     : Ubuntu 22.04+, Debian 12+, Fedora 39+, Arch Linux
# DEPENDE DE  : utils.sh, curl, wget, gpg
# IDEMPOTENTE : Sim — verifica instalação e configuração existentes
# USO DIRETO  : bash ides/vscode-install.sh
# VIA MENU    : Opção 8 do install.sh
# =============================================================================

source "$(dirname "$0")/../scripts/utils.sh"
detect_pkg_manager

CODE_CMD="code"
CONFIG_DIR="$HOME/.config/Code/User"
CONFIG_FILE="$CONFIG_DIR/settings.json"

echo -e "${AZUL}======================================================${RESET}"
echo -e "${VERDE}        VS Code — Claude Code Assist Edition         ${RESET}"
echo -e "${AZUL}======================================================${RESET}"

# =============================================================================
# Dependências
# =============================================================================
install_dependencies() {
    echo -e "${AMARELO}🔍 Verificando dependências...${RESET}"

    case "$PKG_MANAGER" in
        apt)
            sudo apt-get update -qq
            ensure_pkg "wget"
            ensure_pkg "curl"
            ensure_pkg "gpg"
            ensure_pkg "unzip"
            ;;
        dnf)
            ensure_pkg "wget"
            ensure_pkg "curl"
            ensure_pkg "gnupg2"
            ensure_pkg "unzip"
            ;;
        pacman)
            ensure_pkg "wget"
            ensure_pkg "curl"
            ensure_pkg "gnupg"
            ensure_pkg "unzip"
            ;;
    esac
}

# =============================================================================
# Instalação do VS Code
# =============================================================================
install_vscode() {
    # --- Idempotência: verifica se o VS Code já está instalado ---
    if is_installed_cmd "$CODE_CMD"; then
        local current_version
        current_version=$(code --version 2>/dev/null | head -1 || echo "versão desconhecida")
        echo -e "${VERDE}✅ VS Code já está instalado (${current_version}).${RESET}"
        read -rp "Deseja reinstalar / atualizar? [s/N]: " confirm
        [[ ! "$confirm" =~ ^[sS]$ ]] && return 0
    fi

    echo -e "${AMARELO}📥 Adicionando repositório e instalando VS Code...${RESET}"

    case "$PKG_MANAGER" in
        apt)
            local keyring="/usr/share/keyrings/microsoft-archive-keyring.gpg"
            if [[ ! -f "$keyring" ]]; then
                wget -qO - https://packages.microsoft.com/keys/microsoft.asc \
                    | gpg --dearmor \
                    | sudo dd of="$keyring" status=none
            fi

            local sources="/etc/apt/sources.list.d/vscode.list"
            if [[ ! -f "$sources" ]]; then
                echo "deb [arch=amd64,arm64 signed-by=$keyring] https://packages.microsoft.com/repos/code stable main" \
                    | sudo tee "$sources" > /dev/null
            fi

            sudo apt-get update -qq
            ensure_pkg "code"
            ;;
        dnf)
            if [[ ! -f "/etc/yum.repos.d/vscode.repo" ]]; then
                sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                printf '[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\n' \
                    | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
            fi
            ensure_pkg "code"
            ;;
        pacman)
            if is_installed_cmd "yay"; then
                yay -S --noconfirm visual-studio-code-bin
            elif is_installed_cmd "paru"; then
                paru -S --noconfirm visual-studio-code-bin
            else
                echo -e "${VERMELHO}❌ AUR helper não encontrado (yay ou paru). Instale manualmente:${RESET}"
                echo -e "   https://code.visualstudio.com/download"
                exit 1
            fi
            ;;
    esac

    if ! is_installed_cmd "$CODE_CMD"; then
        echo -e "${VERMELHO}❌ Falha ao instalar o VS Code.${RESET}"
        exit 1
    fi

    echo -e "${VERDE}✅ VS Code instalado com sucesso!${RESET}"
}

# =============================================================================
# Instalação de extensões
# =============================================================================
install_extensions() {
    echo -e "${AMARELO}🧩 Instalando extensões...${RESET}"

    local extensions=(
        # IA — Claude Code
        "anthropic.claude-code"
        # PHP / Moodle
        "bmewburn.vscode-intelephense-client"
        "MehediDracula.php-namespace-resolver"
        "imgildev.vscode-moodle-snippets"
        "LMSCloud.mdlcode"
        "junstyle.php-cs-fixer"
        "dawhite.mustache"
        # Docker & Remote
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

    local total=${#extensions[@]}
    local count=0
    local failed=()

    for ext in "${extensions[@]}"; do
        [[ "$ext" == \#* ]] && continue

        count=$((count + 1))
        echo -ne "${AZUL}   [${count}/${total}] ${ext}...${RESET}\r"

        if code --force --install-extension "$ext" &>/dev/null; then
            echo -e "${VERDE}   ✅ [${count}/${total}] ${ext}${RESET}"
        else
            echo -e "${VERMELHO}   ❌ [${count}/${total}] ${ext} (falhou)${RESET}"
            failed+=("$ext")
        fi
    done

    if [[ ${#failed[@]} -gt 0 ]]; then
        echo -e "\n${AMARELO}⚠️  ${#failed[@]} extensão(ões) falharam:${RESET}"
        for f in "${failed[@]}"; do
            echo -e "   - ${f}"
        done
        echo -e "${AMARELO}   Tente instalar manualmente via: code --install-extension <id>${RESET}"
    else
        echo -e "\n${VERDE}✅ Todas as extensões instaladas com sucesso!${RESET}"
    fi
}

# =============================================================================
# Configuração do settings.json
# =============================================================================
apply_settings() {
    echo -e "${AMARELO}⚙️  Aplicando configurações de interface...${RESET}"

    mkdir -p "$CONFIG_DIR"

    # --- Idempotência: não sobrescreve sem confirmação ---
    if [[ -f "$CONFIG_FILE" ]]; then
        echo -e "${AMARELO}⚠️  Configuração existente encontrada em ${CONFIG_FILE}.${RESET}"
        read -rp "Deseja sobrescrever com as configurações LuminaDev? [s/N]: " confirm
        if [[ ! "$confirm" =~ ^[sS]$ ]]; then
            echo -e "${AZUL}↩️  Configuração mantida sem alterações.${RESET}"
            return 0
        fi

        local backup
        backup="${CONFIG_FILE}.bak.$(date +%Y%m%d%H%M%S)"
        cp "$CONFIG_FILE" "$backup"
        echo -e "${AZUL}💾 Backup salvo em: ${backup}${RESET}"
    fi

    cat <<'EOF' > "$CONFIG_FILE"
{
    "telemetry.telemetryLevel": "off",
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
    "editor.minimap.enabled": false,
    "claude.autoStart": true,
    "claude.inlineSuggest.enable": true
}
EOF

    echo -e "${VERDE}✅ Configurações LuminaDev aplicadas em ${CONFIG_FILE}.${RESET}"
}

# =============================================================================
# Execução
# =============================================================================
install_dependencies
install_vscode
install_extensions
apply_settings

echo -e "\n${AZUL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${AMARELO}  Próximos passos:${RESET}"
echo -e "  1. Abra o VS Code: ${VERDE}code .${RESET}"
echo -e "  2. Faça login no Claude: ${VERDE}Ctrl+Shift+P > Claude: Sign In${RESET}"
echo -e "  3. Ative o Intelephense: insira a licença em ${VERDE}Settings > Intelephense${RESET}"
echo -e "${AZUL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
