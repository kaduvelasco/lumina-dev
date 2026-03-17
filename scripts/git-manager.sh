#!/bin/bash

# Cores (Padrão do Projeto)
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Configurações Padrão
DEFAULT_USER="REPLACE_USER"
DEFAULT_EMAIL="REPLACE_EMAIL"
LIBSECRET_PATH="/usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret"

# Função para verificar se o libsecret está disponível
check_libsecret() {
    if [ ! -f "$LIBSECRET_PATH" ]; then
        LIBSECRET_PATH="cache"
    fi
}

# --- GERAÇÃO DE ARQUIVOS (INLINE) ---

create_gitignore() {
    echo -e "${BLUE}📄 Gerando .gitignore (Moodle/Web)...${NC}"
    cat <<EOF > .gitignore
# Logs e Temporários
*.log
.DS_Store
Thumbs.db

# Dependências
node_modules/
vendor/

# IDEs
.idea/
.vscode/
.vscodium/
.zed/
*.swp

# Moodle específico
/moodledata/
/config.php
EOF
    echo -e "${GREEN}✅ .gitignore criado.${NC}"
}

create_aiexclude() {
    echo -e "${BLUE}🛡️ Gerando .aiexclude (Segurança e Performance IA)...${NC}"
    cat <<EOF > .aiexclude
# Bloqueio de arquivos sensíveis
.env
*.pem
*.key
config.php

# Pastas de dados e dependências pesadas
/moodledata/
/vendor/
/node_modules/

# Bloqueio de arquivos binários e mídia (Economia de Tokens)
*.jpg
*.jpeg
*.png
*.gif
*.svg
*.ico
*.mp3
*.mp4
*.webm
*.pdf
*.zip
*.tar.gz
EOF
    echo -e "${GREEN}✅ .aiexclude criado com bloqueio de mídia.${NC}"
}

# --- GESTÃO DE GIT ---

apply_local_configs() {
    if [ ! -d .git ]; then
        echo -e "${RED}❌ Erro: Esta pasta não é um repositório Git.${NC}"
        return 1
    fi

    echo -e "${BLUE}⚙️ Configurando Repositório Local...${NC}"
    read -p "Usuário para este repo [$DEFAULT_USER]: " user_name
    user_name=${user_name:-$DEFAULT_USER}
    read -p "E-mail para este repo [$DEFAULT_EMAIL]: " user_email
    user_email=${user_email:-$DEFAULT_EMAIL}

    # Criar arquivos de projeto
    create_gitignore
    create_aiexclude

    # Aplicar configs no Git
    git config --local user.name "$user_name"
    git config --local user.email "$user_email"
    git config --local credential.helper "$LIBSECRET_PATH"
    git config --local credential.https://github.com.username "$user_name"

    echo -e "${GREEN}✅ Identidade e Proteções de IA aplicadas!${NC}"
    echo -e "👤 $user_name | 📧 $user_email"
}

configure_global() {
    echo -e "${BLUE}🔑 Configuração Global (PAT Token)${NC}"
    read -p "Nome global: " g_user
    read -p "E-mail global: " g_email

    git config --global user.name "$g_user"
    git config --global user.email "$g_email"
    git config --global credential.helper "$LIBSECRET_PATH"

    echo -e "${YELLOW}📌 DICA: Use seu Token (PAT) como senha no primeiro push.${NC}"
    echo -e "${GREEN}✅ Sistema Global configurado.${NC}"
}

init_repo() {
    echo -e "${BLUE}📁 Iniciando novo projeto...${NC}"
    git init -b main
    apply_local_configs
}

clone_repo() {
    read -p "URL do repositório: " repo_url
    read -p "Nome da pasta (opcional): " repo_dir
    git clone "$repo_url" $repo_dir

    target_dir="${repo_dir:-$(basename "$repo_url" .git)}"
    if [ -d "$target_dir" ]; then
        cd "$target_dir" && apply_local_configs && cd ..
    fi
}

# --- EXECUÇÃO ---

check_libsecret

while true; do
    echo -e "\n${BLUE}======================================================${NC}"
    echo -e "  📂 PASTA ATUAL: ${YELLOW}$(pwd)${NC}"
    echo -e "${BLUE}======================================================${NC}"
    echo " 1. Configurar Identidade GLOBAL (Sistema)"
    echo " 2. Iniciar NOVO repositório aqui (com IA/Git files)"
    echo " 3. Clonar repositório e configurar identidade"
    echo " 4. Aplicar Identidade e Arquivos (.gitignore/.aiexclude)"
    echo " 0. Sair"
    echo -e "${BLUE}======================================================${NC}"
    read -p "Escolha uma opção: " opcao

    case $opcao in
        1) configure_global ;;
        2) init_repo ;;
        3) clone_repo ;;
        4) apply_local_configs ;;
        0) exit 0 ;;
        *) echo -e "${RED}Opção inválida!${NC}" ;;
    esac
done
