#!/bin/bash

# ===================================================================================
# dev-linux - Central de Instalação de IDEs e Ferramentas IA
# ===================================================================================

# Cores (Padrão do Projeto)
AZUL='\033[0;34m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
RESET='\033[0m'

# Caminho da pasta atual do script
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIBSECRET_PATH="/usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret"

# --- AUTOMAÇÃO DE PERMISSÕES ---
# Garante que todos os scripts nas subpastas sejam executáveis ao iniciar
echo -e "${AZUL}⚙️  Sincronizando permissões de execução...${RESET}"
find "$BASE_DIR/scripts" -name "*.sh" -exec chmod +x {} + 2>/dev/null
find "$BASE_DIR/ides" -name "*.sh" -exec chmod +x {} + 2>/dev/null

show_header() {
    clear
    echo -e "${AZUL}======================================================${RESET}"
    echo -e "${VERDE}             LUMINA DEV - ELITE WORKSTATION            ${RESET}"
    echo -e "${AZUL}======================================================${RESET}"
}

# Função para executar scripts externos com verificação
run_script() {
    local folder=$1
    local script_name=$2
    if [[ -f "$BASE_DIR/$folder/$script_name" ]]; then
        echo -e "\n${AMARELO}🚀 Executando $folder/$script_name...${RESET}"
        bash "$BASE_DIR/$folder/$script_name"
    else
        echo -e "\n${VERMELHO}⚠️ Erro: Arquivo $script_name não encontrado em $folder/.${RESET}"
        sleep 2
    fi
}

# Opção 3: Instalar o Git Manager como comando global
install_mygit() {
    echo -e "\n${AZUL}👤 Configuração de Identidade Padrão${RESET}"
    read -p "Digite seu nome de usuário GitHub (ex: KaduVelasco): " git_user
    read -p "Digite seu e-mail GitHub (ex: kadu.velasco@provedor.com): " git_email

    if [[ -z "$git_user" || -z "$git_email" ]]; then
        echo -e "${VERMELHO}❌ Erro: Nome e E-mail são obrigatórios para a instalação.${RESET}"
        return 1
    fi

    echo -e "${AMARELO}📦 Personalizando e instalando 'mygit' em /usr/local/bin/...${RESET}"

    if [[ -f "$BASE_DIR/scripts/git-manager.sh" ]]; then
        # Cria uma cópia temporária e substitui os placeholders
        sed -e "s/REPLACE_USER/$git_user/g" \
            -e "s/REPLACE_EMAIL/$git_email/g" \
            "$BASE_DIR/scripts/git-manager.sh" > /tmp/mygit_temp

        sudo cp /tmp/mygit_temp /usr/local/bin/mygit
        sudo chmod +x /usr/local/bin/mygit
        rm /tmp/mygit_temp

        echo -e "${VERDE}✅ Sucesso! O comando 'mygit' foi configurado para $git_user.${RESET}"
    else
        echo -e "${VERMELHO}⚠️ Erro: scripts/git-manager.sh não encontrado.${RESET}"
    fi
}

# Opção 2: Instalar Git e compilar libsecret
install_git_libsecret() {
    echo -e "${AZUL}📦 Verificando dependências e libsecret...${RESET}"
    sudo apt update
    sudo apt install -y git libsecret-1-0 libsecret-1-dev build-essential

    if [ ! -f "$LIBSECRET_PATH" ]; then
        echo -e "${AMARELO}🛠️  Compilando o helper do libsecret para o sistema...${RESET}"
        cd /usr/share/doc/git/contrib/credential/libsecret || exit
        sudo make
        cd - > /dev/null
        echo -e "${VERDE}✅ Compilação concluída.${RESET}"
    else
        echo -e "${VERDE}✅ libsecret já está pronto para uso.${RESET}"
    fi
}

# --- MENU PRINCIPAL ---
while true; do
    show_header
    echo -e "1. Instalar Fontes (JetBrains Mono)"
    echo -e "2. Instalar Git e libsecret"
    echo -e "3. Instalar Git Manager (mygit)"
    echo -e "4. Instalar Claude Code (CLI)"
    echo -e "5. Instalar Gemini Code Assist (CLI)"
    echo -e "6. Instalar Zed Editor (Geral)"
    echo -e "7. Instalar VSCodium (Gemini Edition)"
    echo -e "8. Instalar VSCode (Claude Edition)"
    echo -e "9. Auxiliar Instalação PHPStorm (.tar.gz)"
    echo -e "0. Sair"
    echo -e "${AZUL}------------------------------------------------------${RESET}"
    read -p "Escolha uma opção: " OPTION

    case $OPTION in
        1) run_script "scripts" "fonts-install.sh" ;;
        2) install_git_libsecret ;;
        3) install_mygit ;;
        4) run_script "scripts" "claude-install.sh" ;;
        5) run_script "scripts" "gemini-install.sh" ;;
        6) run_script "ides" "zed-install.sh" ;;
        7) run_script "ides" "vscodium-install.sh" ;;
        8) run_script "ides" "vscode-install.sh" ;;
        9) run_script "ides" "phpstorm-install.sh" ;;
        0) echo -e "${VERDE}Saindo...${RESET}"; exit 0 ;;
        *) echo -e "${VERMELHO}Opção inválida!${RESET}"; sleep 1 ;;
    esac

    echo -e "\n${AZUL}Pressione Enter para voltar ao menu...${RESET}"
    read
done
