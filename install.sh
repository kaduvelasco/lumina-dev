#!/bin/bash

# =============================================================================
# install.sh — LuminaDev - Central de Instalação de IDEs e Ferramentas IA
#
# DESCRIÇÃO   : Menu interativo para configurar um workstation Linux completo
#               para desenvolvimento PHP/Moodle com suporte a ferramentas de IA.
# DISTROS     : Ubuntu 22.04+, Debian 12+, Fedora 39+, Arch Linux
# IDEMPOTENTE : Sim — verifica instalações existentes antes de agir
# USO         : chmod +x install.sh && ./install.sh
# =============================================================================

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Carrega utilitários compartilhados ---
if [[ ! -f "$BASE_DIR/scripts/utils.sh" ]]; then
    echo "❌ Erro fatal: scripts/utils.sh não encontrado. Abortando."
    exit 1
fi
source "$BASE_DIR/scripts/utils.sh"

# --- Detecta o package manager da distro atual ---
detect_pkg_manager

LIBSECRET_PATH="/usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret"

# --- AUTOMAÇÃO DE PERMISSÕES ---
# Garante que todos os scripts nas subpastas sejam executáveis ao iniciar
echo -e "${AZUL}⚙️  Sincronizando permissões de execução...${RESET}"
find "$BASE_DIR/scripts" -name "*.sh" -exec chmod +x {} + 2>/dev/null
find "$BASE_DIR/ides"    -name "*.sh" -exec chmod +x {} + 2>/dev/null

# =============================================================================
# FUNÇÕES AUXILIARES
# =============================================================================

show_header() {
    clear
    echo -e "${AZUL}======================================================${RESET}"
    echo -e "${VERDE}          LUMINA DEV - ELITE WORKSTATION              ${RESET}"
    echo -e "${AZUL}======================================================${RESET}"
    echo -e "${AZUL}  Distro: ${VERDE}${PKG_MANAGER}${AZUL} | Base: ${VERDE}${BASE_DIR}${RESET}"
    echo -e "${AZUL}======================================================${RESET}"
}

# Executa um script externo com verificação de existência
run_script() {
    local folder="$1"
    local script_name="$2"
    local full_path="$BASE_DIR/$folder/$script_name"

    if [[ -f "$full_path" ]]; then
        echo -e "\n${AMARELO}🚀 Executando $folder/$script_name...${RESET}"
        bash "$full_path"
    else
        echo -e "\n${VERMELHO}⚠️  Erro: Arquivo '$script_name' não encontrado em '$folder/'.${RESET}"
        sleep 2
    fi
}

# =============================================================================
# OPÇÃO 3 — Instalar o Git Manager como comando global (mygit)
# =============================================================================
install_mygit() {
    # --- Idempotência: verifica se mygit já existe ---
    if is_installed_cmd "mygit"; then
        local installed_user
        installed_user=$(grep -oP '(?<=GIT_USER=")[^"]+' /usr/local/bin/mygit 2>/dev/null || echo "desconhecido")
        echo -e "\n${VERDE}✅ 'mygit' já está instalado (usuário atual: ${installed_user}).${RESET}"
        read -rp "Deseja reinstalar / atualizar? [s/N]: " confirm
        [[ ! "$confirm" =~ ^[sS]$ ]] && return 0
    fi

    echo -e "\n${AZUL}👤 Configuração de Identidade Padrão${RESET}"
    read -rp "Digite seu nome de usuário GitHub (ex: KaduVelasco): " git_user
    read -rp "Digite seu e-mail GitHub (ex: kadu.velasco@provedor.com): " git_email

    if [[ -z "$git_user" || -z "$git_email" ]]; then
        echo -e "${VERMELHO}❌ Erro: Nome e E-mail são obrigatórios para a instalação.${RESET}"
        return 1
    fi

    if [[ ! -f "$BASE_DIR/scripts/git-manager.sh" ]]; then
        echo -e "${VERMELHO}⚠️  Erro: scripts/git-manager.sh não encontrado.${RESET}"
        return 1
    fi

    echo -e "${AMARELO}📦 Personalizando e instalando 'mygit' em /usr/local/bin/...${RESET}"

    sed -e "s/REPLACE_USER/$git_user/g" \
        -e "s/REPLACE_EMAIL/$git_email/g" \
        "$BASE_DIR/scripts/git-manager.sh" > /tmp/mygit_temp

    sudo cp /tmp/mygit_temp /usr/local/bin/mygit
    sudo chmod +x /usr/local/bin/mygit
    rm -f /tmp/mygit_temp

    echo -e "${VERDE}✅ Sucesso! O comando 'mygit' foi configurado para ${git_user}.${RESET}"
}

# =============================================================================
# OPÇÃO 2 — Instalar Git e compilar libsecret
# =============================================================================
install_git_libsecret() {
    echo -e "${AZUL}📦 Verificando Git e libsecret...${RESET}"

    case "$PKG_MANAGER" in
        apt)
            sudo apt-get update -qq
            ensure_pkg "git"
            ensure_pkg "libsecret-1-0"
            ensure_pkg "libsecret-1-dev"
            ensure_pkg "build-essential"
            ;;
        dnf)
            sudo dnf check-update -q || true
            ensure_pkg "git"
            ensure_pkg "libsecret"
            ensure_pkg "libsecret-devel"
            ensure_pkg "gcc"
            ensure_pkg "make"
            ;;
        pacman)
            sudo pacman -Sy --noconfirm
            ensure_pkg "git"
            ensure_pkg "libsecret"
            ensure_pkg "base-devel"
            ;;
    esac

    # Compilação do helper libsecret (apenas em sistemas apt/Debian-like)
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        if [[ ! -f "$LIBSECRET_PATH" ]]; then
            echo -e "${AMARELO}🛠️  Compilando o helper do libsecret para o sistema...${RESET}"
            cd /usr/share/doc/git/contrib/credential/libsecret || exit 1
            sudo make
            cd - > /dev/null
            echo -e "${VERDE}✅ Compilação concluída.${RESET}"
        else
            echo -e "${VERDE}✅ libsecret já está compilado e pronto para uso.${RESET}"
        fi
    else
        echo -e "${AMARELO}ℹ️  Configuração do libsecret via helper não se aplica a '${PKG_MANAGER}'. Configure manualmente se necessário.${RESET}"
    fi
}

# =============================================================================
# MENU PRINCIPAL
# =============================================================================
while true; do
    show_header
    echo -e "  1. Instalar Fontes (JetBrains Mono)"
    echo -e "  2. Instalar Git e libsecret"
    echo -e "  3. Instalar Git Manager (mygit)"
    echo -e "  4. Instalar Claude Code (CLI)"
    echo -e "  5. Instalar Gemini Code Assist (CLI)"
    echo -e "  6. Instalar Zed Editor (Geral)"
    echo -e "  7. Instalar VSCodium (Gemini Edition)"
    echo -e "  8. Instalar VSCode (Claude Edition)"
    echo -e "  9. Auxiliar Instalação PHPStorm (.tar.gz)"
    echo -e "  0. Sair"
    echo -e "${AZUL}------------------------------------------------------${RESET}"
    read -rp "Escolha uma opção: " OPTION

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
    read -r
done
