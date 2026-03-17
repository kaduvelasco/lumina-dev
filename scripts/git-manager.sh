#!/bin/bash

# =============================================================================
# git-manager.sh — LuminaDev Git Manager (mygit)
#
# DESCRIÇÃO   : Comando global para gerenciar identidade Git, credenciais e
#               geração automática de .gitignore e .aiexclude por projeto.
# DISTROS     : Qualquer distro Linux com Git instalado
# IDEMPOTENTE : Sim — não sobrescreve arquivos existentes sem confirmação
# USO DIRETO  : mygit  (após instalação via install.sh, opção 3)
# ATENÇÃO     : REPLACE_USER e REPLACE_EMAIL são substituídos pelo install.sh
# =============================================================================

source "$(dirname "$0")/../scripts/utils.sh" 2>/dev/null || true

# --- Fallback de cores caso utils.sh não esteja disponível ---
# (este script é copiado para /usr/local/bin, longe do utils.sh)
AZUL="${AZUL:-\033[0;34m}"
VERDE="${VERDE:-\033[0;32m}"
AMARELO="${AMARELO:-\033[1;33m}"
VERMELHO="${VERMELHO:-\033[0;31m}"
RESET="${RESET:-\033[0m}"

# =============================================================================
# CONFIGURAÇÕES PADRÃO (substituídas pelo install.sh via sed)
# =============================================================================
DEFAULT_USER="REPLACE_USER"
DEFAULT_EMAIL="REPLACE_EMAIL"
LIBSECRET_PATH="/usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret"

# =============================================================================
# INICIALIZAÇÃO
# =============================================================================

# Verifica se libsecret está compilado; usa cache como fallback
check_libsecret() {
    if [[ ! -f "$LIBSECRET_PATH" ]]; then
        LIBSECRET_PATH="cache"
    fi
}

# Verifica se o Git está instalado
check_git() {
    if ! command -v git &>/dev/null; then
        echo -e "${VERMELHO}❌ Git não encontrado. Instale via opção 2 do install.sh.${RESET}"
        exit 1
    fi
}

# =============================================================================
# GERAÇÃO DE ARQUIVOS DE PROJETO
# =============================================================================

create_gitignore() {
    # --- Idempotência: não sobrescreve sem confirmação ---
    if [[ -f ".gitignore" ]]; then
        echo -e "${AMARELO}⚠️  .gitignore já existe neste diretório.${RESET}"
        read -rp "Deseja sobrescrever? [s/N]: " confirm
        [[ ! "$confirm" =~ ^[sS]$ ]] && echo -e "${AZUL}↩️  .gitignore mantido sem alterações.${RESET}" && return 0
    fi

    echo -e "${AZUL}📄 Gerando .gitignore (Moodle/Web)...${RESET}"
    cat <<'EOF' > .gitignore
# =============================================================================
# .gitignore — LuminaDev
#
# Modelo padrão para projetos PHP/Moodle.
# Gerado automaticamente pelo comando 'mygit' em cada repositório.
# =============================================================================

# -----------------------------------------------------------------------------
# Sistema operacional
# -----------------------------------------------------------------------------
.DS_Store
.DS_Store?
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/

# -----------------------------------------------------------------------------
# IDEs e editores
# -----------------------------------------------------------------------------
.idea/
.vscode/
.vscodium/
.zed/
*.swp
*.swo
*~
.project
.classpath
.settings/
*.sublime-project
*.sublime-workspace

# -----------------------------------------------------------------------------
# Dependências
# -----------------------------------------------------------------------------
node_modules/
vendor/
bower_components/

# -----------------------------------------------------------------------------
# Build, cache e temporários
# -----------------------------------------------------------------------------
/dist/
/build/
/.cache/
/.tmp/
/tmp/
*.log
*.log.*

# -----------------------------------------------------------------------------
# Moodle específico
# -----------------------------------------------------------------------------
/moodledata/
/config.php
/local/
/theme/*/style/
*.session

# -----------------------------------------------------------------------------
# PHP
# -----------------------------------------------------------------------------
/composer.lock
.env
.env.*
*.env

# -----------------------------------------------------------------------------
# JavaScript / Node
# -----------------------------------------------------------------------------
npm-debug.log*
yarn-debug.log*
yarn-error.log*
yarn.lock
package-lock.json
.npm/
.yarn/

# -----------------------------------------------------------------------------
# Credenciais e segurança
# -----------------------------------------------------------------------------
*.pem
*.key
*.p12
*.pfx
*.cer
*.crt
secrets.*
*.secret
.htpasswd
auth.json
wp-config.php
EOF
    echo -e "${VERDE}✅ .gitignore criado.${RESET}"
}

create_aiexclude() {
    # --- Idempotência: não sobrescreve sem confirmação ---
    if [[ -f ".aiexclude" ]]; then
        echo -e "${AMARELO}⚠️  .aiexclude já existe neste diretório.${RESET}"
        read -rp "Deseja sobrescrever? [s/N]: " confirm
        [[ ! "$confirm" =~ ^[sS]$ ]] && echo -e "${AZUL}↩️  .aiexclude mantido sem alterações.${RESET}" && return 0
    fi

    echo -e "${AZUL}🛡️  Gerando .aiexclude (Segurança e Performance IA)...${RESET}"
    cat <<'EOF' > .aiexclude
# =============================================================================
# .aiexclude — LuminaDev AI Shield
#
# Impede que ferramentas de IA (Claude Code, Gemini Code Assist) processem
# arquivos sensíveis, binários e dados pesados desnecessários.
# Gerado automaticamente pelo comando 'mygit' em cada repositório.
# =============================================================================

# -----------------------------------------------------------------------------
# Credenciais e arquivos sensíveis
# -----------------------------------------------------------------------------
.env
.env.*
*.pem
*.key
*.p12
*.pfx
*.cer
*.crt
config.php
wp-config.php
secrets.*
*.secret
.htpasswd
auth.json

# -----------------------------------------------------------------------------
# Pastas de dados e dependências pesadas
# -----------------------------------------------------------------------------
/moodledata/
/vendor/
/node_modules/
/bower_components/
/.git/

# -----------------------------------------------------------------------------
# Build, cache e temporários
# -----------------------------------------------------------------------------
/dist/
/build/
/.cache/
/.tmp/
/tmp/
*.log
*.lock
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# -----------------------------------------------------------------------------
# Binários e mídia (economia de tokens)
# -----------------------------------------------------------------------------

# Imagens
*.jpg
*.jpeg
*.png
*.gif
*.svg
*.ico
*.webp
*.bmp
*.tiff
*.tif
*.heic
*.raw

# Vídeo e áudio
*.mp3
*.mp4
*.webm
*.ogg
*.wav
*.flac
*.avi
*.mov
*.mkv
*.wmv

# Documentos e arquivos compactados
*.pdf
*.zip
*.tar.gz
*.tar.bz2
*.rar
*.7z
*.gz
*.iso

# Fontes
*.ttf
*.otf
*.woff
*.woff2
*.eot

# Binários compilados e executáveis
*.exe
*.dll
*.so
*.dylib
*.bin
*.out
*.class
*.pyc
EOF
    echo -e "${VERDE}✅ .aiexclude criado com bloqueio de segurança e mídia.${RESET}"
}

# =============================================================================
# GESTÃO DE IDENTIDADE E CREDENCIAIS
# =============================================================================

apply_local_configs() {
    if [[ ! -d ".git" ]]; then
        echo -e "${VERMELHO}❌ Esta pasta não é um repositório Git.${RESET}"
        return 1
    fi

    echo -e "${AZUL}⚙️  Configurando identidade local do repositório...${RESET}"

    # Mostra identidade atual antes de sobrescrever
    local current_user current_email
    current_user=$(git config --local user.name 2>/dev/null || echo "não definido")
    current_email=$(git config --local user.email 2>/dev/null || echo "não definido")
    echo -e "${AMARELO}   Identidade atual: ${current_user} <${current_email}>${RESET}"

    read -rp "Usuário para este repo [${DEFAULT_USER}]: " user_name
    user_name="${user_name:-$DEFAULT_USER}"

    read -rp "E-mail para este repo [${DEFAULT_EMAIL}]: " user_email
    user_email="${user_email:-$DEFAULT_EMAIL}"

    # Gera arquivos de projeto
    create_gitignore
    create_aiexclude

    # Aplica configurações locais
    git config --local user.name "$user_name"
    git config --local user.email "$user_email"
    git config --local credential.helper "$LIBSECRET_PATH"
    git config --local credential.https://github.com.username "$user_name"

    echo -e "${VERDE}✅ Identidade e proteções de IA aplicadas!${RESET}"
    echo -e "   👤 ${user_name} | 📧 ${user_email}"
}

configure_global() {
    echo -e "${AZUL}🔑 Configuração Global de Identidade Git${RESET}"

    # Mostra configuração global atual
    local current_user current_email
    current_user=$(git config --global user.name 2>/dev/null || echo "não definido")
    current_email=$(git config --global user.email 2>/dev/null || echo "não definido")
    echo -e "${AMARELO}   Configuração atual: ${current_user} <${current_email}>${RESET}"

    read -rp "Nome global: " g_user
    read -rp "E-mail global: " g_email

    if [[ -z "$g_user" || -z "$g_email" ]]; then
        echo -e "${VERMELHO}❌ Nome e e-mail não podem ser vazios.${RESET}"
        return 1
    fi

    git config --global user.name "$g_user"
    git config --global user.email "$g_email"
    git config --global credential.helper "$LIBSECRET_PATH"

    echo -e "${AMARELO}📌 DICA: Use seu Token (PAT) como senha no primeiro push.${RESET}"
    echo -e "${VERDE}✅ Configuração global atualizada: ${g_user} <${g_email}>${RESET}"
}

init_repo() {
    if [[ -d ".git" ]]; then
        echo -e "${AMARELO}⚠️  Esta pasta já é um repositório Git.${RESET}"
        read -rp "Deseja reinicializar e reaplicar as configurações? [s/N]: " confirm
        [[ ! "$confirm" =~ ^[sS]$ ]] && return 0
    fi

    echo -e "${AZUL}📁 Iniciando novo repositório Git...${RESET}"
    git init -b main
    apply_local_configs
}

clone_repo() {
    read -rp "URL do repositório: " repo_url

    if [[ -z "$repo_url" ]]; then
        echo -e "${VERMELHO}❌ URL não pode ser vazia.${RESET}"
        return 1
    fi

    read -rp "Nome da pasta (Enter para usar o padrão): " repo_dir

    if git clone "$repo_url" ${repo_dir:+"$repo_dir"}; then
        local target_dir="${repo_dir:-$(basename "$repo_url" .git)}"
        if [[ -d "$target_dir" ]]; then
            echo -e "${AZUL}⚙️  Aplicando configurações no repositório clonado...${RESET}"
            cd "$target_dir" && apply_local_configs && cd ..
        fi
    else
        echo -e "${VERMELHO}❌ Falha ao clonar o repositório. Verifique a URL e sua conexão.${RESET}"
        return 1
    fi
}

show_header() {
    echo -e "\n${AZUL}======================================================${RESET}"
    echo -e "  📂 PASTA ATUAL: ${AMARELO}$(pwd)${RESET}"
    echo -e "  👤 USUÁRIO:     ${AMARELO}${DEFAULT_USER}${RESET}"
    echo -e "${AZUL}======================================================${RESET}"
    echo "  1. Configurar identidade GLOBAL (sistema)"
    echo "  2. Iniciar NOVO repositório aqui"
    echo "  3. Clonar repositório e configurar identidade"
    echo "  4. Aplicar identidade e arquivos neste repo"
    echo "  0. Sair"
    echo -e "${AZUL}======================================================${RESET}"
}

# =============================================================================
# EXECUÇÃO
# =============================================================================
check_git
check_libsecret

while true; do
    show_header
    read -rp "Escolha uma opção: " opcao
    case $opcao in
        1) configure_global ;;
        2) init_repo ;;
        3) clone_repo ;;
        4) apply_local_configs ;;
        0) echo -e "${VERDE}Saindo...${RESET}"; exit 0 ;;
        *) echo -e "${VERMELHO}Opção inválida!${RESET}" ;;
    esac
done
