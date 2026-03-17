#!/bin/bash

# =============================================================================
# gemini-install.sh — Instalação do Gemini Code Assist CLI
#
# DESCRIÇÃO   : Instala o @google/gemini-cli globalmente via npm, verificando
#               e instalando o Node.js caso necessário.
# DISTROS     : Ubuntu 22.04+, Debian 12+, Fedora 39+, Arch Linux
# DEPENDE DE  : utils.sh, curl, Node.js 18+
# IDEMPOTENTE : Sim — verifica se o Gemini CLI já está instalado
# USO DIRETO  : bash scripts/gemini-install.sh
# VIA MENU    : Opção 5 do install.sh
# =============================================================================

source "$(dirname "$0")/../scripts/utils.sh"
detect_pkg_manager

GEMINI_PKG="@google/gemini-cli"
GEMINI_CMD="gemini"
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
# Instalação do Gemini CLI
# =============================================================================
install_gemini() {
    # --- Idempotência: verifica se o Gemini CLI já está instalado ---
    if is_installed_cmd "$GEMINI_CMD"; then
        local current_version
        current_version=$(gemini --version 2>/dev/null || echo "versão desconhecida")
        echo -e "${VERDE}✅ Gemini CLI já está instalado (${current_version}).${RESET}"
        read -rp "Deseja reinstalar / atualizar para a versão mais recente? [s/N]: " confirm
        [[ ! "$confirm" =~ ^[sS]$ ]] && return 0
    fi

    # --- Verifica ou instala o Node.js ---
    if ! is_installed_cmd "node" || ! check_node_version; then
        install_node
    fi

    echo -e "${AZUL}🚀 Instalando ${GEMINI_PKG} globalmente...${RESET}"

    if sudo npm install -g "$GEMINI_PKG"; then
        echo -e "${VERDE}✅ Gemini CLI instalado com sucesso!${RESET}"
        echo -e "\n${AZUL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -e "${AMARELO}  Próximos passos:${RESET}"
        echo -e "  1. Acesse ${AZUL}https://aistudio.google.com/apikey${RESET} e gere sua chave."
        echo -e "  2. Adicione ao seu shell (${AMARELO}~/.bashrc${RESET} ou ${AMARELO}~/.zshrc${RESET}):"
        echo -e "     ${VERDE}export GOOGLE_API_KEY='sua_chave_aqui'${RESET}"
        echo -e "  3. Recarregue o shell: ${VERDE}source ~/.bashrc${RESET}"
        echo -e "  4. Teste com: ${VERDE}gemini --version${RESET}"
        echo -e "${AZUL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    else
        echo -e "${VERMELHO}❌ Falha ao instalar via npm. Verifique as permissões e tente novamente.${RESET}"
        exit 1
    fi
}

install_gemini
