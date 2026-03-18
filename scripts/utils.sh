#!/bin/bash

# =============================================================================
# utils.sh — Utilitários compartilhados do LuminaDev
#
# DESCRIÇÃO   : Módulo central com funções de detecção de distro, cores,
#               verificações de idempotência e instalação de pacotes.
#               Deve ser carregado via 'source' por todos os outros scripts.
# DISTROS     : Ubuntu 22.04+, Debian 12+, Fedora 39+, Arch Linux
# USO         : source "$(dirname "$0")/../scripts/utils.sh"
#               source "$(dirname "$0")/scripts/utils.sh"  # a partir da raiz
# =============================================================================

# Proteção contra carregamento duplo
[[ -n "$_LUMINA_UTILS_LOADED" ]] && return 0
_LUMINA_UTILS_LOADED=1

# =============================================================================
# Cores (Padrão LuminaDev)
# =============================================================================
AZUL='\033[0;34m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
RESET='\033[0m'

# =============================================================================
# Detecção de package manager
# =============================================================================
detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then
        PKG_MANAGER="apt"
        PKG_INSTALL="sudo apt-get install -y"
        PKG_UPDATE="sudo apt-get update -qq"
    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
        PKG_INSTALL="sudo dnf install -y"
        PKG_UPDATE="sudo dnf check-update -q || true"
    elif command -v pacman &>/dev/null; then
        PKG_MANAGER="pacman"
        PKG_INSTALL="sudo pacman -S --noconfirm"
        PKG_UPDATE="sudo pacman -Sy --noconfirm"
    else
        echo -e "${VERMELHO}❌ Package manager não suportado. Use apt, dnf ou pacman.${RESET}"
        exit 1
    fi

    export PKG_MANAGER PKG_INSTALL PKG_UPDATE
}

# =============================================================================
# Verificações de idempotência
# =============================================================================

# Verifica se um comando existe no PATH
is_installed_cmd() {
    command -v "$1" &>/dev/null
}

# Verifica se um pacote está instalado no sistema
is_installed_pkg() {
    case "${PKG_MANAGER:-}" in
        apt)    dpkg -s "$1" &>/dev/null 2>&1 ;;
        dnf)    rpm -q "$1" &>/dev/null 2>&1 ;;
        pacman) pacman -Qi "$1" &>/dev/null 2>&1 ;;
        *)      return 1 ;;
    esac
}

# Verifica se um arquivo ou diretório existe
is_installed_path() {
    [[ -e "$1" ]]
}

# =============================================================================
# Instalação de pacotes
# =============================================================================

# Instala um pacote apenas se ainda não estiver presente
ensure_pkg() {
    local pkg="$1"

    if is_installed_pkg "$pkg"; then
        echo -e "${VERDE}✅ ${pkg} já está instalado. Pulando.${RESET}"
        return 0
    fi

    echo -e "${AMARELO}📥 Instalando ${pkg}...${RESET}"

    case "${PKG_MANAGER:-}" in
        apt)    sudo apt-get install -y "$pkg" ;;
        dnf)    sudo dnf install -y "$pkg" ;;
        pacman) sudo pacman -S --noconfirm "$pkg" ;;
        *)
            echo -e "${VERMELHO}❌ PKG_MANAGER não definido. Execute detect_pkg_manager primeiro.${RESET}"
            return 1
            ;;
    esac
}

# Instala um comando apenas se ainda não existir no PATH
# Retorna 0 se pode instalar, 1 se já está instalado
ensure_cmd() {
    local cmd="$1"
    local label="${2:-$cmd}"

    if is_installed_cmd "$cmd"; then
        echo -e "${VERDE}✅ ${label} já está instalado. Pulando.${RESET}"
        return 1
    fi

    return 0
}

# =============================================================================
# Utilitários gerais
# =============================================================================

# Exibe uma linha separadora com título opcional
print_section() {
    local title="${1:-}"
    echo -e "\n${AZUL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    [[ -n "$title" ]] && echo -e "${AMARELO}  ${title}${RESET}"
}

# Verifica se o script está sendo executado como root
require_not_root() {
    if [[ "$EUID" -eq 0 ]]; then
        echo -e "${VERMELHO}❌ Não execute este script como root. Use seu usuário normal.${RESET}"
        echo -e "${AMARELO}   O script solicitará sudo quando necessário.${RESET}"
        exit 1
    fi
}

# Verifica se sudo está disponível e funcional
require_sudo() {
    if ! command -v sudo &>/dev/null; then
        echo -e "${VERMELHO}❌ sudo não encontrado. Instale-o e tente novamente.${RESET}"
        exit 1
    fi

    if ! sudo -v &>/dev/null; then
        echo -e "${VERMELHO}❌ Falha ao obter permissões sudo. Verifique suas credenciais.${RESET}"
        exit 1
    fi
}

# Verifica se há conexão com a internet
require_internet() {
    echo -e "${AZUL}🌐 Verificando conexão com a internet...${RESET}"
    if ! curl -fsSL --max-time 5 https://1.1.1.1 &>/dev/null; then
        echo -e "${VERMELHO}❌ Sem conexão com a internet. Verifique sua rede.${RESET}"
        exit 1
    fi
    echo -e "${VERDE}✅ Conexão OK.${RESET}"
}

# Imprime a versão de um comando de forma segura
print_version() {
    local cmd="$1"
    local version_flag="${2:---version}"

    if is_installed_cmd "$cmd"; then
        local version
        version=$("$cmd" "$version_flag" 2>/dev/null | head -1)
        echo -e "${VERDE}   ${cmd}: ${version}${RESET}"
    else
        echo -e "${AMARELO}   ${cmd}: não instalado${RESET}"
    fi
}
