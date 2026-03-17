#!/bin/bash

# =============================================================================
# phpstorm-install.sh — Instalador auxiliar do PHPStorm
#
# DESCRIÇÃO   : Extrai e instala o PHPStorm a partir de um pacote .tar.gz
#               baixado manualmente do site da JetBrains, criando link
#               simbólico e atalho no menu do sistema.
# DISTROS     : Qualquer distro Linux com tar e sudo
# DEPENDE DE  : utils.sh
# IDEMPOTENTE : Sim — detecta versão instalada e confirma antes de substituir
# USO DIRETO  : bash ides/phpstorm-install.sh
# VIA MENU    : Opção 9 do install.sh
# ATENÇÃO     : Baixe o .tar.gz em https://www.jetbrains.com/phpstorm/download
# =============================================================================

source "$(dirname "$0")/../scripts/utils.sh"

INSTALL_DIR="/opt/phpstorm"
SYMLINK="/usr/local/bin/phpstorm"
DESKTOP_FILE="/usr/share/applications/phpstorm.desktop"

echo -e "${AZUL}======================================================${RESET}"
echo -e "${VERDE}          INSTALADOR AUXILIAR PHPSTORM               ${RESET}"
echo -e "${AZUL}======================================================${RESET}"

# =============================================================================
# Solicita e valida o arquivo .tar.gz
# =============================================================================
get_file_path() {
    echo -e "${AMARELO}📂 Arraste o arquivo .tar.gz para cá ou digite o caminho completo:${RESET}"
    read -rp "> " FILE_PATH

    # Remove aspas simples ou duplas que podem vir ao arrastar o arquivo no terminal
    FILE_PATH=$(echo "$FILE_PATH" | sed "s/['\"]//g" | xargs)

    if [[ -z "$FILE_PATH" ]]; then
        echo -e "${VERMELHO}❌ Nenhum caminho informado. Abortando.${RESET}"
        exit 1
    fi

    if [[ ! -f "$FILE_PATH" ]]; then
        echo -e "${VERMELHO}❌ Arquivo não encontrado: '${FILE_PATH}'${RESET}"
        exit 1
    fi

    if [[ "$FILE_PATH" != *.tar.gz ]]; then
        echo -e "${VERMELHO}❌ O arquivo precisa ser um pacote .tar.gz oficial da JetBrains.${RESET}"
        exit 1
    fi

    # Tenta extrair a versão do nome do arquivo (ex: PhpStorm-2024.1.4.tar.gz)
    PHPSTORM_VERSION=$(basename "$FILE_PATH" | grep -oP '\d+\.\d+(\.\d+)?' | head -1)
    if [[ -n "$PHPSTORM_VERSION" ]]; then
        echo -e "${VERDE}✅ Pacote reconhecido: PHPStorm ${PHPSTORM_VERSION}${RESET}"
    else
        echo -e "${AMARELO}⚠️  Não foi possível identificar a versão pelo nome do arquivo.${RESET}"
    fi
}

# =============================================================================
# Verifica instalação existente
# =============================================================================
check_existing() {
    if [[ -d "$INSTALL_DIR" ]]; then
        local installed_version=""
        local build_file="$INSTALL_DIR/product-info.json"

        if [[ -f "$build_file" ]]; then
            installed_version=$(grep -oP '(?<="version"\s:\s")[^"]+' "$build_file" 2>/dev/null || echo "desconhecida")
        fi

        echo -e "${AMARELO}⚠️  PHPStorm já está instalado em ${INSTALL_DIR} (versão: ${installed_version}).${RESET}"
        read -rp "Deseja substituir pela versão ${PHPSTORM_VERSION:-nova}? [s/N]: " confirm
        [[ ! "$confirm" =~ ^[sS]$ ]] && echo -e "${AZUL}↩️  Instalação cancelada.${RESET}" && exit 0
    fi
}

# =============================================================================
# Remove versão anterior
# =============================================================================
cleanup_old() {
    echo -e "${AMARELO}🗑️  Removendo versão anterior em ${INSTALL_DIR}...${RESET}"
    sudo rm -rf "$INSTALL_DIR"
    sudo rm -f "$SYMLINK"
    sudo rm -f "$DESKTOP_FILE"
    echo -e "${VERDE}✅ Versão anterior removida.${RESET}"
}

# =============================================================================
# Extração e instalação
# =============================================================================
install_phpstorm() {
    echo -e "${AZUL}📦 Extraindo pacote para ${INSTALL_DIR}...${RESET}"

    local temp_dir
    temp_dir=$(mktemp -d)
    trap 'sudo rm -rf "$temp_dir"' EXIT

    if ! sudo tar -xzf "$FILE_PATH" -C "$temp_dir" --strip-components=1; then
        echo -e "${VERMELHO}❌ Falha ao extrair o pacote. O arquivo pode estar corrompido.${RESET}"
        exit 1
    fi

    sudo mv "$temp_dir" "$INSTALL_DIR"
    trap - EXIT  # Remove o trap após mover com sucesso

    # Garante que o binário principal é executável
    sudo chmod +x "$INSTALL_DIR/bin/phpstorm.sh"

    echo -e "${VERDE}✅ Arquivos extraídos para ${INSTALL_DIR}.${RESET}"
}

# =============================================================================
# Link simbólico
# =============================================================================
create_symlink() {
    echo -e "${AZUL}🔗 Criando link simbólico em ${SYMLINK}...${RESET}"
    sudo ln -sf "$INSTALL_DIR/bin/phpstorm.sh" "$SYMLINK"
    echo -e "${VERDE}✅ Link criado: ${SYMLINK}${RESET}"
}

# =============================================================================
# Atalho no menu do sistema (.desktop)
# =============================================================================
create_desktop_entry() {
    echo -e "${AZUL}🖥️  Criando atalho no menu do sistema...${RESET}"

    # Detecta o ícone disponível (svg tem prioridade, fallback para png)
    local icon_path="$INSTALL_DIR/bin/phpstorm.svg"
    [[ ! -f "$icon_path" ]] && icon_path="$INSTALL_DIR/bin/phpstorm.png"

    cat <<EOF | sudo tee "$DESKTOP_FILE" > /dev/null
[Desktop Entry]
Version=1.0
Type=Application
Name=PHPStorm
Icon=${icon_path}
Exec="${INSTALL_DIR}/bin/phpstorm.sh" %f
Comment=The Lightning-smart PHP IDE
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-phpstorm
MimeType=text/x-php;
EOF

    # Atualiza o cache de aplicações do sistema
    if is_installed_cmd "update-desktop-database"; then
        sudo update-desktop-database /usr/share/applications &>/dev/null
    fi

    echo -e "${VERDE}✅ Atalho criado em ${DESKTOP_FILE}.${RESET}"
}

# =============================================================================
# Execução
# =============================================================================
get_file_path
check_existing
cleanup_old
install_phpstorm
create_symlink
create_desktop_entry

echo -e "\n${AZUL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${VERDE}  ✅ PHPStorm ${PHPSTORM_VERSION:-} instalado com sucesso!${RESET}"
echo -e "${AMARELO}  Próximos passos:${RESET}"
echo -e "  1. Inicie pelo terminal: ${VERDE}phpstorm${RESET}"
echo -e "  2. Ou pelo menu do sistema: busque por ${VERDE}PHPStorm${RESET}"
echo -e "  3. Na primeira execução, ative sua licença JetBrains."
echo -e "  4. Para integrar o Claude: instale o plugin ${VERDE}Claude AI${RESET} via"
echo -e "     ${VERDE}Settings > Plugins > Marketplace${RESET}"
echo -e "${AZUL}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
