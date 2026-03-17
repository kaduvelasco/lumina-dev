#!/bin/bash

# =============================================================================
# fonts-install.sh — Instalação da fonte JetBrains Mono
#
# DESCRIÇÃO   : Baixa e instala a JetBrains Mono no diretório de fontes do
#               usuário atual e atualiza o cache de fontes do sistema.
# DISTROS     : Qualquer distro Linux com curl, unzip e fontconfig
# IDEMPOTENTE : Sim — verifica se a fonte já está instalada antes de baixar
# USO DIRETO  : bash scripts/fonts-install.sh
# VIA MENU    : Opção 1 do install.sh
# =============================================================================

source "$(dirname "$0")/../scripts/utils.sh"

FONT_NAME="JetBrains Mono"
FONT_VERSION="2.304"
FONT_URL="https://github.com/JetBrains/JetBrainsMono/releases/download/v${FONT_VERSION}/JetBrainsMono-${FONT_VERSION}.zip"
FONT_DIR="$HOME/.local/share/fonts"
FONT_CHECK="JetBrainsMono-Regular.ttf"

# =============================================================================
# Verifica dependências necessárias
# =============================================================================
check_dependencies() {
    local missing=()

    for cmd in curl unzip fc-cache; do
        if ! is_installed_cmd "$cmd"; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${AMARELO}📥 Instalando dependências ausentes: ${missing[*]}${RESET}"
        detect_pkg_manager
        for pkg in "${missing[@]}"; do
            case "$pkg" in
                fc-cache) ensure_pkg "fontconfig" ;;
                *)        ensure_pkg "$pkg" ;;
            esac
        done
    fi
}

# =============================================================================
# Instalação da fonte
# =============================================================================
install_fonts() {
    # --- Idempotência: verifica se a fonte já está instalada ---
    if [[ -f "$FONT_DIR/$FONT_CHECK" ]]; then
        echo -e "${VERDE}✅ ${FONT_NAME} já está instalada em ${FONT_DIR}.${RESET}"
        read -rp "Deseja reinstalar / atualizar para a v${FONT_VERSION}? [s/N]: " confirm
        [[ ! "$confirm" =~ ^[sS]$ ]] && return 0
    fi

    check_dependencies

    echo -e "${AMARELO}🔤 Iniciando instalação da fonte ${FONT_NAME} v${FONT_VERSION}...${RESET}"

    mkdir -p "$FONT_DIR"

    local TEMP_DIR
    TEMP_DIR=$(mktemp -d)

    # Garante limpeza do diretório temporário ao sair (erro ou sucesso)
    trap 'rm -rf "$TEMP_DIR"' EXIT

    echo -e "${AZUL}📥 Baixando fontes oficiais...${RESET}"
    if ! curl -fsSL "$FONT_URL" -o "$TEMP_DIR/fonts.zip"; then
        echo -e "${VERMELHO}❌ Erro ao baixar as fontes. Verifique sua conexão.${RESET}"
        return 1
    fi

    echo -e "${AZUL}📦 Extraindo arquivos...${RESET}"
    if ! unzip -q "$TEMP_DIR/fonts.zip" -d "$TEMP_DIR"; then
        echo -e "${VERMELHO}❌ Erro ao extrair o arquivo zip.${RESET}"
        return 1
    fi

    # Copia apenas os TTFs (evita arquivos de documentação e webfonts)
    local count
    count=$(find "$TEMP_DIR" -name "*.ttf" | wc -l)

    if [[ "$count" -eq 0 ]]; then
        echo -e "${VERMELHO}❌ Nenhum arquivo .ttf encontrado no pacote baixado.${RESET}"
        return 1
    fi

    find "$TEMP_DIR" -name "*.ttf" -exec cp {} "$FONT_DIR/" \;
    echo -e "${VERDE}📁 ${count} arquivos copiados para ${FONT_DIR}.${RESET}"

    echo -e "${AMARELO}🔄 Atualizando cache de fontes do sistema...${RESET}"
    fc-cache -f

    echo -e "${VERDE}✅ ${FONT_NAME} v${FONT_VERSION} instalada com sucesso!${RESET}"
}

install_fonts
