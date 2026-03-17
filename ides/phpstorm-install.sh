#!/bin/bash

# Cores (Padrão do Projeto)
AZUL='\033[0;34m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
RESET='\033[0m'

echo -e "${AZUL}======================================================${RESET}"
echo -e "${VERDE}           INSTALADOR AUXILIAR PHPSTORM              ${RESET}"
echo -e "${AZUL}======================================================${RESET}"

# 1. Solicitar o caminho do arquivo
echo -e "${AMARELO}📂 Por favor, arraste o arquivo .tar.gz para cá ou digite o caminho:${RESET}"
read -p "> " FILE_PATH

# Remove aspas simples ou duplas que podem vir ao arrastar o arquivo no terminal
FILE_PATH=$(echo "$FILE_PATH" | sed "s/['\"]//g")

# 2. Validar o arquivo
if [ ! -f "$FILE_PATH" ]; then
    echo -e "${VERMELHO}❌ Erro: O arquivo '$FILE_PATH' não foi encontrado!${RESET}"
    exit 1
fi

if [[ ! "$FILE_PATH" == *.tar.gz ]]; then
    echo -e "${VERMELHO}❌ Erro: O arquivo precisa ser um pacote .tar.gz oficial da JetBrains.${RESET}"
    exit 1
fi

# 3. Limpeza de versões anteriores
echo -e "${AMARELO}🗑️ Removendo versões antigas em /opt/phpstorm...${RESET}"
sudo rm -Rf /opt/phpstorm*
sudo rm -f /usr/bin/phpstorm
sudo rm -f /usr/share/applications/phpstorm.desktop

# 4. Instalação
echo -e "${AZUL}📦 Extraindo pacotes para /opt/...${RESET}"
# Criamos uma pasta temporária para evitar problemas com nomes de pastas variáveis dentro do tar
sudo mkdir -p /opt/phpstorm_temp
sudo tar -xzf "$FILE_PATH" -C /opt/phpstorm_temp --strip-components=1

# Move para o local final e limpa o temp
sudo mv /opt/phpstorm_temp /opt/phpstorm

# Criar link simbólico para execução via terminal
sudo ln -sf /opt/phpstorm/bin/phpstorm.sh /usr/bin/phpstorm

# 5. Criar Atalho no Menu (.desktop)
echo -e "${AZUL}🖥️ Criando atalho no menu do sistema...${RESET}"
cat <<EOF | sudo tee /usr/share/applications/phpstorm.desktop > /dev/null
[Desktop Entry]
Version=1.0
Type=Application
Name=PHPStorm
Icon=/opt/phpstorm/bin/phpstorm.svg
Exec="/opt/phpstorm/bin/phpstorm.sh" %f
Comment=The Lightning-smart PHP IDE
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-phpstorm
EOF

echo -e "${VERDE}✅ PHPStorm instalado com sucesso!${RESET}"
echo -e "${AMARELO}Dica: Agora você pode iniciá-lo digitando 'phpstorm' ou pelo menu.${RESET}"
