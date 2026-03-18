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
            cd - > /dev/null || return 1
            echo -e "${VERDE}✅ Compilação concluída.${RESET}"
        else
            echo -e "${VERDE}✅ libsecret já está compilado e pronto para uso.${RESET}"
        fi
    else
        echo -e "${AMARELO}ℹ️  Configuração do libsecret via helper não se aplica a '${PKG_MANAGER}'. Configure manualmente se necessário.${RESET}"
    fi
}

# =============================================================================
# OPÇÃO 6 — Configurar Gemini Code Assist
# =============================================================================
configure_gemini() {
    echo -e "\n${AZUL}🔑 Configuração do Gemini Code Assist${RESET}"

    # --- Verifica se o Gemini CLI está instalado ---
    if ! is_installed_cmd "gemini"; then
        echo -e "${VERMELHO}❌ Gemini CLI não encontrado. Execute a opção 5 primeiro.${RESET}"
        return 1
    fi

    # --- Solicita a API Key ---
    echo -e "${AMARELO}📌 Obtenha sua chave em: ${AZUL}https://aistudio.google.com/apikey${RESET}"
    echo -e "${AMARELO}   Crie uma conta Google, acesse o link acima e clique em 'Create API Key'.${RESET}"
    read -rp "Cole sua GOOGLE_API_KEY aqui: " api_key

    if [[ -z "$api_key" ]]; then
        echo -e "${VERMELHO}❌ Chave não informada. Configuração abortada.${RESET}"
        return 1
    fi

    # --- Exporta para a sessão atual ---
    export GOOGLE_API_KEY="$api_key"

    # --- Persiste no .bashrc (evita duplicatas) ---
    local bashrc="$HOME/.bashrc"
    local export_line="export GOOGLE_API_KEY='${api_key}'"

    if grep -q "GOOGLE_API_KEY" "$bashrc" 2>/dev/null; then
        # Atualiza a linha existente
        sed -i "s|.*GOOGLE_API_KEY.*|${export_line}|" "$bashrc"
        echo -e "${AZUL}🔄 GOOGLE_API_KEY atualizada no ${bashrc}.${RESET}"
    else
        echo "$export_line" >> "$bashrc"
        echo -e "${VERDE}✅ GOOGLE_API_KEY adicionada ao ${bashrc}.${RESET}"
    fi

    # --- Recarrega o .bashrc ---
    # shellcheck source=/dev/null
    source "$bashrc"
    echo -e "${VERDE}✅ .bashrc recarregado.${RESET}"

    # --- Verifica o Gemini CLI ---
    echo -e "${AZUL}🔍 Verificando instalação do Gemini CLI...${RESET}"

    local version_output
    version_output=$(gemini --version 2>&1)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]] || echo "$version_output" | grep -q "ENOENT\|Cannot read properties"; then
        echo -e "${AMARELO}⚠️  Detectado problema no diretório de configuração. Aplicando correção...${RESET}"

        mkdir -p "$HOME/.gemini"
        if [[ ! -f "$HOME/.gemini/projects.json" ]] || ! grep -q "projects" "$HOME/.gemini/projects.json" 2>/dev/null; then
            echo '{"projects":[]}' > "$HOME/.gemini/projects.json"
            echo -e "${VERDE}✅ projects.json criado corretamente.${RESET}"
        fi

        # Testa novamente após a correção
        version_output=$(gemini --version 2>&1)
        if echo "$version_output" | grep -q "^[0-9]"; then
            echo -e "${VERDE}✅ Gemini CLI funcionando! Versão: ${version_output}${RESET}"
        else
            echo -e "${VERMELHO}❌ Problema persistente. Tente reinstalar via opção 5.${RESET}"
            return 1
        fi
    else
        echo -e "${VERDE}✅ Gemini CLI funcionando! Versão: ${version_output}${RESET}"
    fi

    echo -e "\n${AZUL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${AMARELO}  Próximos passos:${RESET}"
    echo -e "  1. Abra um novo terminal ou execute: ${VERDE}source ~/.bashrc${RESET}"
    echo -e "  2. Teste com: ${VERDE}gemini${RESET}"
    echo -e "${AZUL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
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
    echo -e "  6. Configurar Gemini Code Assist"
    echo -e "  7. Instalar Zed Editor (Geral)"
    echo -e "  8. Instalar VSCodium (Gemini Edition)"
    echo -e "  9. Instalar VSCode (Claude Edition)"
    echo -e "  10. Auxiliar Instalação PHPStorm (.tar.gz)"
    echo -e "  0. Sair"
    echo -e "${AZUL}------------------------------------------------------${RESET}"
    read -rp "Escolha uma opção: " OPTION

    case $OPTION in
        1)  run_script "scripts" "fonts-install.sh" ;;
        2)  install_git_libsecret ;;
        3)  install_mygit ;;
        4)  run_script "scripts" "claude-install.sh" ;;
        5)  run_script "scripts" "gemini-install.sh" ;;
        6)  configure_gemini ;;
        7)  run_script "ides" "zed-install.sh" ;;
        8)  run_script "ides" "vscodium-install.sh" ;;
        9)  run_script "ides" "vscode-install.sh" ;;
        10) run_script "ides" "phpstorm-install.sh" ;;
        0)  echo -e "${VERDE}Saindo...${RESET}"; exit 0 ;;
        *)  echo -e "${VERMELHO}Opção inválida!${RESET}"; sleep 1 ;;
    esac

    echo -e "\n${AZUL}Pressione Enter para voltar ao menu...${RESET}"
    read -r
done
