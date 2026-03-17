#!/bin/bash

# =============================================================================
# claude-install.sh — Instalação do Claude Code CLI
#
# DESCRIÇÃO   : Instala o Claude Code CLI via instalador oficial da Anthropic,
#               verificando e instalando o Node.js caso necessário.
# DISTROS     : Ubuntu 22.04+, Debian 12+, Fedora 39+, Arch Linux
# DEPENDE DE  : utils.sh, curl, Node.js 18+
# IDEMPOTENTE : Sim — verifica se o Claude Code já está instalado
# USO DIRETO  : bash scripts/claude-install.sh
# VIA MENU    : Opção 4 do install.sh
# =============================================================================

source "$(dirname "$0")/../scripts/utils.sh"
detect_pkg_manager

CLAUDE_CMD="claude"
NODE_MIN_VERSION=18

# =============================================================================
# Verifica se a versão do Node.js atende ao requisito mínimo
# =============================================================================
check_node_version() {
    local version
    version=$(node -e "console.log(process.version.slice(1).split('.')[0])" 2>/dev/null)

    if [[ -z "$version" ]]; then
        return 1
    fi

    if [[ "$version" -lt "$NODE_MIN_VERSION" ]]; then
        echo -e "${AMARELO}⚠️  Node.js v${version} encontrado, mas é necessário v${NODE_MIN_VERSION}+.${RESET}"
        return 1
    fi

    echo -e "${VERDE}✅ Node.js v${version} encontrado.${RESET}"
    return 0
}

# =============================================================================
# Instala o Node.js via NodeSource (LTS mais recente)
# =============================================================================
install_node() {
    echo -e "${AMARELO}📥 Instalando Node.js LTS via NodeSource...${RESET}"

    case "$PKG_MANAGER" in
        apt)
            if ! is_installed_cmd "curl"; then
                ensure_pkg "curl"
            fi
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            ensure_pkg "nodejs"
            ;;
        dnf)
            curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
            ensure_pkg "nodejs"
            ;;
        pacman)
            ensure_pkg "nodejs"
            ensure_pkg "npm"
            ;;
    esac

    if ! is_installed_cmd "node"; then
        echo -e "${VERMELHO}❌ Falha ao instalar o Node.js. Verifique sua conexão e tente novamente.${RESET}"
        exit 1
    fi

    echo -e "${VERDE}✅ Node.js $(node -v) instalado com sucesso.${RESET}"
}

# =============================================================================
# Instalação do Claude Code CLI
# =============================================================================
install_claude() {
    # --- Idempotência: verifica se o Claude Code já está instalado ---
    if is_installed_cmd "$CLAUDE_CMD"; then
        local current_version
        current_version=$(claude --version 2>/dev/null || echo "versão desconhecida")
        echo -e "${VERDE}✅ Claude Code já está instalado (${current_version}).${RESET}"
        read -rp "Deseja reinstalar / atualizar para a versão mais recente? [s/N]: " confirm
        [[ ! "$confirm" =~ ^[sS]$ ]] && return 0
    fi

    # --- Verifica ou instala o Node.js ---
    if ! is_installed_cmd "node" || ! check_node_version; then
        echo -e "${AMARELO}O Claude Code requer o Node.js v${NODE_MIN_VERSION}+.${RESET}"
        read -rp "Deseja instalar agora? [S/n]: " install_node_confirm
        [[ "$install_node_confirm" =~ ^[Nn]$ ]] && echo -e "${VERMELHO}Instalação abortada.${RESET}" && exit 1
        install_node
    fi

    # --- Instalação via script oficial da Anthropic ---
    echo -e "${AZUL}📥 Executando instalador oficial da Anthropic...${RESET}"

    if curl -fsSL https://claude.ai/install.sh | bash; then
        echo -e "${VERDE}✅ Claude Code instalado com sucesso!${RESET}"
        echo -e "\n${AZUL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -e "${AMARELO}  Próximos passos:${RESET}"
        echo -e "  1. Execute ${VERDE}claude${RESET} no terminal para iniciar o login."
        echo -e "  2. Autentique com sua conta em ${AZUL}https://claude.ai${RESET}"
        echo -e "  3. Navegue até um projeto e execute ${VERDE}claude${RESET} para começar."
        echo -e "${AZUL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    else
        echo -e "${VERMELHO}❌ Erro durante a execução do instalador oficial.${RESET}"
        echo -e "${AMARELO}   Tente manualmente: curl -fsSL https://claude.ai/install.sh | bash${RESET}"
        exit 1
    fi
}

install_claude
