#!/bin/bash

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

install_fonts() {
    # Verificar dependências
    for cmd in curl unzip fc-cache; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "${RED}❌ Erro: O comando '$cmd' não está instalado.${NC}"
            return 1
        fi
    done

    echo -e "${YELLOW}Iniciando instalação da fonte JetBrains Mono...${NC}"

    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"

    echo -e "${BLUE}Baixando fontes oficiais...${NC}"
    TEMP_DIR=$(mktemp -d)
    # Versão mais recente estável
    URL="https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip"

    if curl -L "$URL" -o "$TEMP_DIR/fonts.zip"; then
        unzip -q "$TEMP_DIR/fonts.zip" -d "$TEMP_DIR"

        # Copia apenas os TTFs (evita arquivos desnecessários de documentação)
        find "$TEMP_DIR" -name "*.ttf" -exec cp -v {} "$FONT_DIR/" \; | wc -l | xargs -I {} echo -e "${GREEN}Copiadas {} fontes para $FONT_DIR${NC}"

        echo -e "${YELLOW}Atualizando cache de fontes do sistema...${NC}"
        fc-cache -f
        echo -e "${GREEN}✅ Fontes instaladas com sucesso!${NC}"
    else
        echo -e "${RED}❌ Erro ao baixar fontes. Verifique sua conexão.${NC}"
    fi
    rm -rf "$TEMP_DIR"
}

install_fonts
