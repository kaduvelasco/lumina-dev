#!/bin/bash

# =============================================================================
# zed-install.sh — Instalação e configuração do Zed Editor
#
# DESCRIÇÃO   : Instala o Zed Editor via script oficial e aplica configurações
#               com tema JetBrains, fontes e suporte a PHP/Moodle.
# DISTROS     : Ubuntu 22.04+, Debian 12+, Fedora 39+, Arch Linux
# DEPENDE DE  : utils.sh, curl
# IDEMPOTENTE : Sim — verifica instalação e configuração existentes
# USO DIRETO  : bash ides/zed-install.sh
# VIA MENU    : Opção 6 do install.sh
# =============================================================================

source "$(dirname "$0")/../scripts/utils.sh"
detect_pkg_manager

ZED_CMD="zed"
ZED_CONFIG_DIR="$HOME/.config/zed"
ZED_CONFIG_FILE="$ZED_CONFIG_DIR/settings.json"
LOCAL_BIN="$HOME/.local/bin"

# =============================================================================
# Cabeçalho
# =============================================================================
echo -e "${AZUL}======================================================${RESET}"
echo -e "${VERDE}          INSTALADOR ZED EDITOR (GERAL)              ${RESET}"
echo -e "${AZUL}======================================================${RESET}"

# =============================================================================
# Dependências
# =============================================================================
install_dependencies() {
    echo -e "${AMARELO}🔍 Verificando dependências...${RESET}"

    case "$PKG_MANAGER" in
        apt)
            sudo apt-get update -qq
            ensure_pkg "curl"
            ensure_pkg "tar"
            ensure_pkg "xz-utils"
            ensure_pkg "unzip"
            ;;
        dnf)
            ensure_pkg "curl"
            ensure_pkg "tar"
            ensure_pkg "xz"
            ensure_pkg "unzip"
            ;;
        pacman)
            ensure_pkg "curl"
            ensure_pkg "tar"
            ensure_pkg "xz"
            ensure_pkg "unzip"
            ;;
    esac
}

# =============================================================================
# Instalação do Zed
# =============================================================================
install_zed() {
    # --- Idempotência: verifica se o Zed já está instalado ---
    if is_installed_cmd "$ZED_CMD"; then
        local current_version
        current_version=$(zed --version 2>/dev/null || echo "versão desconhecida")
        echo -e "${VERDE}✅ Zed já está instalado (${current_version}).${RESET}"
        read -rp "Deseja reinstalar / atualizar para a versão mais recente? [s/N]: " confirm
        [[ ! "$confirm" =~ ^[sS]$ ]] && return 0
    fi

    echo -e "${AMARELO}📥 Baixando e instalando Zed via script oficial...${RESET}"

    if ! curl -fsSL https://zed.dev/install.sh | sh; then
        echo -e "${VERMELHO}❌ Falha ao instalar o Zed. Verifique sua conexão e tente novamente.${RESET}"
        exit 1
    fi

    # --- Garante que ~/.local/bin está no PATH ---
    if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
        echo -e "${AMARELO}⚙️  Adicionando ${LOCAL_BIN} ao PATH...${RESET}"

        # Adiciona ao .bashrc e .zshrc se existirem
        local path_line='export PATH="$HOME/.local/bin:$PATH"'
        grep -qxF "$path_line" "$HOME/.bashrc" 2>/dev/null || echo "$path_line" >> "$HOME/.bashrc"
        [[ -f "$HOME/.zshrc" ]] && grep -qxF "$path_line" "$HOME/.zshrc" || echo "$path_line" >> "$HOME/.zshrc" 2>/dev/null

        export PATH="$LOCAL_BIN:$PATH"
        echo -e "${VERDE}✅ PATH atualizado. Reinicie o terminal para aplicar permanentemente.${RESET}"
    fi

    echo -e "${VERDE}✅ Zed instalado com sucesso!${RESET}"
}

# =============================================================================
# Configuração do Zed (settings.json)
# =============================================================================
apply_settings() {
    echo -e "${AMARELO}🛠️  Aplicando configurações personalizadas...${RESET}"

    mkdir -p "$ZED_CONFIG_DIR"

    # --- Idempotência: não sobrescreve configuração existente sem confirmação ---
    if [[ -f "$ZED_CONFIG_FILE" ]]; then
        echo -e "${AMARELO}⚠️  Configuração existente encontrada em ${ZED_CONFIG_FILE}.${RESET}"
        read -rp "Deseja sobrescrever com as configurações LuminaDev? [s/N]: " confirm
        if [[ ! "$confirm" =~ ^[sS]$ ]]; then
            echo -e "${AZUL}↩️  Configuração mantida sem alterações.${RESET}"
            return 0
        fi

        # Backup da configuração anterior
        local backup="${ZED_CONFIG_FILE}.bak.$(date +%Y%m%d%H%M%S)"
        cp "$ZED_CONFIG_FILE" "$backup"
        echo -e "${AZUL}💾 Backup salvo em: ${backup}${RESET}"
    fi

    cat <<'EOF' > "$ZED_CONFIG_FILE"
{
  "theme": "One Dark",
  "ui_font_family": "JetBrains Mono",
  "buffer_font_family": "JetBrains Mono",
  "buffer_font_size": 14,
  "ui_font_size": 14,
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
      "format_on_save": "on",
      "tab_size": 4
    },
    "JavaScript": {
      "tab_size": 2,
      "format_on_save": "on"
    },
    "TypeScript": {
      "tab_size": 2,
      "format_on_save": "on"
    }
  }
}
EOF

    echo -e "${VERDE}✅ Configurações LuminaDev aplicadas em ${ZED_CONFIG_FILE}.${RESET}"
}

# =============================================================================
# Execução
# =============================================================================
install_dependencies
install_zed
apply_settings

echo -e "\n${AZUL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${AMARELO}  Próximos passos:${RESET}"
echo -e "  1. Execute ${VERDE}zed .${RESET} para abrir o editor na pasta atual."
echo -e "  2. Instale extensões PHP: ${VERDE}phpactor${RESET} ou ${VERDE}intelephense${RESET}."
echo -e "  3. Para usar IA: configure o ${VERDE}Claude${RESET} em Settings > Assistant."
echo -e "${AZUL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
