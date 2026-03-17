#!/bin/bash

# ===================================================================================
# LuminaDev - Script de Desinstalação Completa
# ===================================================================================

# Cores (Padrão LuminaDev)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'
NC='\033[0m'

show_header() {
    clear
    echo -e "${RED}======================================================${RESET}"
    echo -e "${YELLOW}           LUMINA DEV - FERRAMENTA DE REMOÇÃO         ${RESET}"
    echo -e "${RED}======================================================${RESET}"
}

# --- FUNÇÕES DE REMOÇÃO ---

remove_vscode() {
    echo -e "${YELLOW}🗑️ Removendo VSCode oficial e Claude Edition...${NC}"
    sudo apt purge code -y && sudo apt autoremove -y
    rm -rf "$HOME/.vscode" "$HOME/.config/Code"
    echo -e "${GREEN}✅ VSCode removido.${NC}"
}

remove_vscodium() {
    echo -e "${YELLOW}🗑️ Removendo VSCodium e Gemini Edition...${NC}"
    sudo apt purge codium -y && sudo apt autoremove -y
    rm -rf "$HOME/.vscode-oss" "$HOME/.config/VSCodium"
    echo -e "${GREEN}✅ VSCodium removido.${NC}"
}

remove_zed() {
    echo -e "${YELLOW}🗑️ Removendo Zed Editor...${NC}"
    rm -rf "$HOME/.local/bin/zed" "$HOME/.local/zed.app" "$HOME/.config/zed" "$HOME/.local/share/zed"
    echo -e "${GREEN}✅ Zed removido.${NC}"
}

remove_phpstorm() {
    echo -e "${YELLOW}🗑️ Removendo PHPStorm de /opt/phpstorm...${NC}"
    sudo rm -rf /opt/phpstorm*
    sudo rm -f /usr/bin/phpstorm
    sudo rm -f /usr/share/applications/phpstorm.desktop
    echo -e "${GREEN}✅ PHPStorm removido.${NC}"
}

remove_mygit() {
    echo -e "${YELLOW}🗑️ Removendo comando 'mygit' global...${NC}"
    sudo rm -f /usr/local/bin/mygit
    echo -e "${GREEN}✅ Comando mygit removido.${NC}"
}

remove_clis_ia() {
    echo -e "${YELLOW}🗑️ Removendo CLIs de IA (Claude e Gemini)...${NC}"
    # Remove via NPM caso tenham sido instalados globalmente
    sudo npm uninstall -g @anthropic-ai/claude-code 2>/dev/null
    # Caso existam outros binários ou configs
    rm -rf "$HOME/.claude-code" "$HOME/.gemini-assist"
    echo -e "${GREEN}✅ CLIs de IA removidas.${NC}"
}

# --- MENU PRINCIPAL ---
while true; do
    show_header
    echo -e "1) Remover VSCode (Claude Edition)"
    echo -e "2) Remover VSCodium (Gemini Edition)"
    echo -e "3) Remover Zed Editor"
    echo -e "4) Remover PHPStorm"
    echo -e "5) Remover comando 'mygit'"
    echo -e "6) Remover CLIs de IA (Claude/Gemini)"
    echo -e "0) Sair"
    echo -e "${RED}------------------------------------------------------${NC}"
    read -p "Escolha o que deseja desinstalar: " OPTION

    case $OPTION in
        1) remove_vscode ;;
        2) remove_vscodium ;;
        3) remove_zed ;;
        4) remove_phpstorm ;;
        5) remove_mygit ;;
        6) remove_clis_ia ;;
        0) echo -e "${GREEN}Saindo do LuminaDev Uninstaller...${NC}"; exit 0 ;;
        *) echo -e "${RED}Opção inválida!${NC}"; sleep 1 ;;
    esac

    echo -e "\n${BLUE}Pressione Enter para voltar ao menu...${NC}"
    read
done
