#!/bin/bash

# =============================================================================
# vscodium-install.sh — Instalação e configuração do VSCodium (Gemini Edition)
#
# DESCRIÇÃO   : Instala o VSCodium via repositório oficial, aplica extensões
#               focadas em Gemini + PHP/Moodle/Docker e configura a interface
#               com ergonomia JetBrains.
# DISTROS     : Ubuntu 22.04+, Debian 12+, Fedora 39+, Arch Linux
# DEPENDE DE  : utils.sh, curl, wget, gpg
# IDEMPOTENTE : Sim — verifica instalação e configuração existentes
# USO DIRETO  : bash ides/vscodium-install.sh
# VIA MENU    : Opção 7 do install.sh
# =============================================================================

source "$(dirname "$0")/../scripts/utils.sh"
detect_pkg_manager

CODIUM_CMD="codium"
CONFIG_DIR="$HOME/.config/VSCodium/User"
CONFIG_FILE="$CONFIG_DIR/settings.json"

echo -e "${AZUL}======================================================${RESET}"
echo -e "${VERDE}       VSCodium — Gemini Code Assist Edition         ${RESET}"
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
# Instalação do VSCodium
# =============================================================================
install_vscodium() {
    # --- Idempotência: verifica se o VSCodium já está instalado ---
    if is_installed_cmd "$CODIUM_CMD"; then
        local current_version
        current_version=$(codium --version 2>/dev/null | head -1 || echo "versão desconhecida")
        echo -e "${VERDE}✅ VSCodium já está instalado (${current_version}).${RESET}"
        read -rp "Deseja reinstalar / atualizar? [s/N]: " confirm
        [[ ! "$confirm" =~ ^[sS]$ ]] && return 0
    fi

    echo -e "${AMARELO}📥 Adicionando repositório e instalando VSCodium...${RESET}"

    case "$PKG_MANAGER" in
        apt)
            # Adiciona chave GPG apenas se ainda não existir
            local keyring="/usr/share/keyrings/vscodium-archive-keyring.gpg"
            if [[ ! -f "$keyring" ]]; then
                wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
                    | gpg --dearmor \
                    | sudo dd of="$keyring" status=none
            fi

            # Adiciona source list apenas se ainda não existir
            local sources="/etc/apt/sources.list.d/vscodium.sources"
            if [[ ! -f "$sources" ]]; then
                printf 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg\n' \
                    | sudo tee "$sources" > /dev/null
            fi

            sudo apt-get update -qq
            ensure_pkg "codium"
            ;;
        dnf)
            if [[ ! -f "/etc/yum.repos.d/vscodium.repo" ]]; then
                sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
                printf '[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg\nmetadata_expire=1h\n' \
                    | sudo tee /etc/yum.repos.d/vscodium.repo > /dev/null
            fi
            ensure_pkg "codium"
            ;;
        pacman)
            # No Arch, VSCodium está no AUR
            if is_installed_cmd "yay"; then
                yay -S --noconfirm vscodium-bin
            elif is_installed_cmd "paru"; then
                paru -S --noconfirm vscodium-bin
            else
                echo -e "${VERMELHO}❌ AUR helper não encontrado (yay ou paru). Instale manualmente:${RESET}"
                echo -e "   https://vscodium.com/#install"
                exit 1
            fi
            ;;
    esac

    if ! is_installed_cmd "$CODIUM_CMD"; then
        echo -e "${VERMELHO}❌ Falha ao instalar o VSCodium.${RESET}"
        exit 1
    fi

    echo -e "${VERDE}✅ VSCodium instalado com sucesso!${RESET}"
}

# =============================================================================
# Instalação de extensões
# =============================================================================
install_extensions() {
    echo -e "${AMARELO}🧩 Instalando extensões...${RESET}"

    local extensions=(
        # IA
        "google.gemini-code-assist"
        # PHP / Moodle
        "bmewburn.vscode-intelephense-client"
        "mehedi-hassan.php-namespace-resolver"
        "imgildev.vscode-moodle-snippets"
        "fischerman.mdlcode"
        "junstyle.php-cs-fixer"
        "terryfly.vscode-mustache"
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
        # Pula comentários no array (linhas que começam com #)
        [[ "$ext" == \#* ]] && continue

        count=$((count + 1))
        echo -ne "${AZUL}   [${count}/${total}] ${ext}...${RESET}\r"

        if codium --force --install-extension "$ext" &>/dev/null; then
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
        echo -e "${AMARELO}   Tente instalar manualmente via: codium --install-extension <id>${RESET}"
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

        # Backup da configuração anterior
        local backup="${CONFIG_FILE}.bak.$(date +%Y%m%d%H%M%S)"
        cp "$CONFIG_FILE" "$backup"
        echo -e "${AZUL}💾 Backup salvo em: ${backup}${RESET}"
    fi

    cat <<'EOF' > "$CONFIG_FILE"
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

    echo -e "${VERDE}✅ Configurações LuminaDev aplicadas em ${CONFIG_FILE}.${RESET}"
}

# =============================================================================
# Execução
# =============================================================================
install_dependencies
install_vscodium
install_extensions
apply_settings

echo -e "\n${AZUL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${AMARELO}  Próximos passos:${RESET}"
echo -e "  1. Abra o VSCodium: ${VERDE}codium .${RESET}"
echo -e "  2. Faça login no Gemini: ${VERDE}Ctrl+Shift+P > Gemini: Sign In${RESET}"
echo -e "  3. Active o Intelephense: insira a licença em ${VERDE}Settings > Intelephense${RESET}"
echo -e "${AZUL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
