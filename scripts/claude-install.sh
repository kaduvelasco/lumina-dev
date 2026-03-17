#!/bin/bash

# Cores para o script isolado
AZUL='\033[0;34m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
RESET='\033[0m'

echo -e "${AZUL}🚀 Iniciando instalação do Claude Code CLI...${RESET}"

# Verifica se o Node.js está instalado (requisito para o Claude Code)
if ! command -v npm &> /dev/null; then
    echo -e "${VERMELHO}❌ Erro: npm (Node.js) não encontrado.${RESET}"
    echo -e "${AMARELO}O Claude Code requer o Node.js. Deseja instalar agora? (s/n)${RESET}"
    read -r install_node
    if [[ "$install_node" =~ ^[Ss]$ ]]; then
        echo -e "${AZUL}📦 Instalando Node.js e NPM...${RESET}"
        sudo apt update && sudo apt install -y nodejs npm
    else
        echo -e "${VERMELHO}Instalação abortada. Instale o Node.js e tente novamente.${RESET}"
        exit 1
    fi
fi

# Instalação oficial via script da Anthropic
echo -e "${AZUL}📥 Baixando e executando instalador oficial...${RESET}"
if curl -fsSL https://claude.ai/install.sh | bash; then
    echo -e "${VERDE}✅ Claude Code instalado com sucesso!${RESET}"
    echo -e "${AMARELO}Dica: Digite 'claude' no terminal para iniciar o login.${RESET}"
else
    echo -e "${VERMELHO}❌ Ocorreu um erro durante a execução do script oficial.${RESET}"
    exit 1
fi
