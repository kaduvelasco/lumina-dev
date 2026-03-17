#!/bin/bash

# =============================================================================
# uninstall.sh — LuminaDev - Ferramenta de Remoção
#
# DESCRIÇÃO   : Menu interativo para remover individualmente as ferramentas
#               instaladas pelo LuminaDev, com confirmação antes de cada ação.
# DISTROS     : Ubuntu 22.04+, Debian 12+, Fedora 39+, Arch Linux
# DEPENDE DE  : utils.sh
# USO         : chmod +x uninstall.sh && ./uninstall.sh
# =============================================================================

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Carrega utilitários compartilhados ---
if [[ ! -f "$BASE_DIR/scripts/utils.sh" ]]; then
    echo "❌ Erro fatal: scripts/utils.sh não encontrado. Abortando."
    exit 1
fi
source "$BASE_DIR/scripts/utils.sh"
detect_pkg_manager

# =============================================================================
# Helpers
# =============================================================================

# Exige confirmação explícita antes de remover qualquer coisa
confirm_removal() {
    local label="$1"
    echo -e "${VERMELHO}⚠️  Você está prestes a remover: ${label}${RESET}"
    read -rp "Tem certeza? Esta ação não pode ser desfeita. [s/N]: " confirm
    [[ "$confirm" =~ ^[sS]$ ]]
}

# Remove pacote via package manager da distro atual
remove_pkg() {
    local pkg="$1"
    case "$PKG_MANAGER" in
        apt)
            if is_installed_pkg "$pkg"; then
                sudo apt-get purge -y "$pkg" && sudo apt-get autoremove -y
            else
                echo -e "${AMARELO}⚠️  Pacote '${pkg}' não encontrado via apt.${RESET}"
            fi
            ;;
        dnf)
            if is_installed_pkg "$pkg"; then
                sudo dnf remove -y "$pkg"
            else
                echo -e "${AMARELO}⚠️  Pacote '${pkg}' não encontrado via dnf.${RESET}"
            fi
            ;;
        pacman)
            if is_installed_pkg "$pkg"; then
                sudo pacman -Rns --noconfirm "$pkg"
            else
                echo -e "${AMARELO}⚠️  Pacote '${pkg}' não encontrado via pacman.${RESET}"
            fi
            ;;
    esac
}

# =============================================================================
# Funções de remoção
# =============================================================================

remove_vscode() {
    confirm_removal "VS Code (Claude Edition)" || return 0

    echo -e "${AMARELO}🗑️  Removendo VS Code...${RESET}"

    remove_pkg "code"

    # Remove repositório e chave GPG (apt)
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo rm -f /etc/apt/sources.list.d/vscode.list
        sudo rm -f /usr/share/keyrings/microsoft-archive-keyring.gpg
        sudo apt-get update -qq
    fi

    # Remove configurações e dados do usuário
    local dirs=(
        "$HOME/.vscode"
        "$HOME/.config/Code"
    )
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            rm -rf "$dir"
            echo -e "${VERDE}   🗂️  Removido: ${dir}${RESET}"
        fi
    done

    echo -e "${VERDE}✅ VS Code removido com sucesso.${RESET}"
}

remove_vscodium() {
    confirm_removal "VSCodium (Gemini Edition)" || return 0

    echo -e "${AMARELO}🗑️  Removendo VSCodium...${RESET}"

    remove_pkg "codium"

    # Remove repositório e chave GPG (apt)
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo rm -f /etc/apt/sources.list.d/vscodium.sources
        sudo rm -f /usr/share/keyrings/vscodium-archive-keyring.gpg
        sudo apt-get update -qq
    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        sudo rm -f /etc/yum.repos.d/vscodium.repo
    fi

    # Remove configurações e dados do usuário
    local dirs=(
        "$HOME/.vscode-oss"
        "$HOME/.config/VSCodium"
    )
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            rm -rf "$dir"
            echo -e "${VERDE}   🗂️  Removido: ${dir}${RESET}"
        fi
    done

    echo -e "${VERDE}✅ VSCodium removido com sucesso.${RESET}"
}

remove_zed() {
    confirm_removal "Zed Editor" || return 0

    echo -e "${AMARELO}🗑️  Removendo Zed Editor...${RESET}"

    local paths=(
        "$HOME/.local/bin/zed"
        "$HOME/.local/zed.app"
        "$HOME/.config/zed"
        "$HOME/.local/share/zed"
    )
    for path in "${paths[@]}"; do
        if [[ -e "$path" ]]; then
            rm -rf "$path"
            echo -e "${VERDE}   🗂️  Removido: ${path}${RESET}"
        else
            echo -e "${AMARELO}   ⚠️  Não encontrado: ${path}${RESET}"
        fi
    done

    echo -e "${VERDE}✅ Zed Editor removido com sucesso.${RESET}"
}

remove_phpstorm() {
    confirm_removal "PHPStorm (/opt/phpstorm)" || return 0

    echo -e "${AMARELO}🗑️  Removendo PHPStorm...${RESET}"

    local paths=(
        "/opt/phpstorm"
        "/usr/local/bin/phpstorm"
        "/usr/bin/phpstorm"
        "/usr/share/applications/phpstorm.desktop"
    )
    for path in "${paths[@]}"; do
        if [[ -e "$path" ]]; then
            sudo rm -rf "$path"
            echo -e "${VERDE}   🗂️  Removido: ${path}${RESET}"
        fi
    done

    # Atualiza cache de aplicações
    if is_installed_cmd "update-desktop-database"; then
        sudo update-desktop-database /usr/share/applications &>/dev/null
    fi

    echo -e "${VERDE}✅ PHPStorm removido com sucesso.${RESET}"
}

remove_mygit() {
    confirm_removal "comando 'mygit' (/usr/local/bin/mygit)" || return 0

    echo -e "${AMARELO}🗑️  Removendo comando 'mygit'...${RESET}"

    if [[ -f "/usr/local/bin/mygit" ]]; then
        sudo rm -f /usr/local/bin/mygit
        echo -e "${VERDE}✅ Comando 'mygit' removido com sucesso.${RESET}"
    else
        echo -e "${AMARELO}⚠️  Comando 'mygit' não encontrado em /usr/local/bin.${RESET}"
    fi
}

remove_clis_ia() {
    confirm_removal "CLIs de IA (Claude Code e Gemini CLI)" || return 0

    echo -e "${AMARELO}🗑️  Removendo CLIs de IA...${RESET}"

    # Claude Code
    if is_installed_cmd "claude"; then
        echo -e "${AZUL}   Removendo Claude Code...${RESET}"
        sudo npm uninstall -g @anthropic-ai/claude-code 2>/dev/null \
            && echo -e "${VERDE}   ✅ Claude Code removido.${RESET}" \
            || echo -e "${AMARELO}   ⚠️  Falha ao remover via npm. Tente manualmente.${RESET}"
    else
        echo -e "${AMARELO}   ⚠️  Claude Code não encontrado.${RESET}"
    fi

    # Gemini CLI
    if is_installed_cmd "gemini"; then
        echo -e "${AZUL}   Removendo Gemini CLI...${RESET}"
        sudo npm uninstall -g @google/gemini-cli 2>/dev/null \
            && echo -e "${VERDE}   ✅ Gemini CLI removido.${RESET}" \
            || echo -e "${AMARELO}   ⚠️  Falha ao remover via npm. Tente manualmente.${RESET}"
    else
        echo -e "${AMARELO}   ⚠️  Gemini CLI não encontrado.${RESET}"
    fi

    # Remove diretórios de configuração residuais
    local dirs=(
        "$HOME/.claude"
        "$HOME/.claude-code"
        "$HOME/.gemini"
        "$HOME/.gemini-assist"
    )
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            rm -rf "$dir"
            echo -e "${VERDE}   🗂️  Removido: ${dir}${RESET}"
        fi
    done

    echo -e "${VERDE}✅ CLIs de IA removidas com sucesso.${RESET}"
}

remove_fonts() {
    confirm_removal "JetBrains Mono (~/.local/share/fonts)" || return 0

    echo -e "${AMARELO}🗑️  Removendo JetBrains Mono...${RESET}"

    local font_dir="$HOME/.local/share/fonts"
    local count
    count=$(find "$font_dir" -name "JetBrainsMono*" 2>/dev/null | wc -l)

    if [[ "$count" -eq 0 ]]; then
        echo -e "${AMARELO}⚠️  Nenhum arquivo JetBrains Mono encontrado em ${font_dir}.${RESET}"
        return 0
    fi

    find "$font_dir" -name "JetBrainsMono*" -delete
    fc-cache -f
    echo -e "${VERDE}✅ ${count} arquivo(s) de fonte removidos e cache atualizado.${RESET}"
}

# =============================================================================
# Menu principal
# =============================================================================
show_header() {
    clear
    echo -e "${VERMELHO}======================================================${RESET}"
    echo -e "${AMARELO}         LUMINA DEV — FERRAMENTA DE REMOÇÃO          ${RESET}"
    echo -e "${VERMELHO}======================================================${RESET}"
    echo -e "${VERMELHO}  Distro: ${AMARELO}${PKG_MANAGER}${RESET}"
    echo -e "${VERMELHO}======================================================${RESET}"
}

while true; do
    show_header
    echo -e "  1) Remover VS Code (Claude Edition)"
    echo -e "  2) Remover VSCodium (Gemini Edition)"
    echo -e "  3) Remover Zed Editor"
    echo -e "  4) Remover PHPStorm"
    echo -e "  5) Remover comando 'mygit'"
    echo -e "  6) Remover CLIs de IA (Claude / Gemini)"
    echo -e "  7) Remover fontes JetBrains Mono"
    echo -e "  0) Sair"
    echo -e "${VERMELHO}------------------------------------------------------${RESET}"
    read -rp "Escolha o que deseja desinstalar: " OPTION

    case $OPTION in
        1) remove_vscode ;;
        2) remove_vscodium ;;
        3) remove_zed ;;
        4) remove_phpstorm ;;
        5) remove_mygit ;;
        6) remove_clis_ia ;;
        7) remove_fonts ;;
        0) echo -e "${VERDE}Saindo do LuminaDev Uninstaller...${RESET}"; exit 0 ;;
        *) echo -e "${VERMELHO}Opção inválida!${RESET}"; sleep 1 ;;
    esac

    echo -e "\n${AZUL}Pressione Enter para voltar ao menu...${RESET}"
    read -r
done
