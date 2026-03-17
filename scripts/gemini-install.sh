#!/bin/bash

# Cores
AZUL='\033[0;34m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
RESET='\033[0m'

echo -e "${AZUL}🚀 Instalando Gemini Code Assist CLI...${RESET}"

# Verifica se o Node.js está instalado
if ! command -v npm &> /dev/null; then
    echo -e "${VERMELHO}❌ Erro: npm (Node.js) não encontrado.${RESET}"
    echo -e "${AMARELO}O Gemini CLI requer o Node.js. Instalando via apt...${RESET}"
    sudo apt update && sudo apt install -y nodejs npm
fi

# Instalação global do Gemini CLI
echo -e "${AZUL}📥 Instalando @google/gemini-cli globalmente...${RESET}"
if sudo npm install -g @google/gemini-cli; then
    echo -e "${VERDE}✅ Gemini CLI instalado com sucesso!${RESET}"
    echo -e "${AMARELO}Dica: Você precisará da sua API KEY do Google AI Studio.${RESET}"
    echo -e "Configure-a com: export GOOGLE_API_KEY='sua_chave'${RESET}"
else
    echo -e "${VERMELHO}❌ Erro ao instalar via NPM. Verifique as permissões.${RESET}"
    exit 1
fi
