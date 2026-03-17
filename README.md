# 💡 LuminaDev — Elite Workstation Setup

> Automação de workstation Linux para desenvolvedores PHP/Moodle com ergonomia JetBrains e proteção nativa para uso de IA.

![License](https://img.shields.io/badge/license-GPL--3.0-blue)
![Shell](https://img.shields.io/badge/shell-bash-green)
![Distros](https://img.shields.io/badge/distros-Ubuntu%20%7C%20Debian%20%7C%20Fedora%20%7C%20Arch-orange)
![CI](https://img.shields.io/github/actions/workflow/status/kaduvelasco/lumina-dev/lint.yml?label=lint%20%26%20smoke%20test)

---

## 📋 Índice

- [Sobre o projeto](#-sobre-o-projeto)
- [Diferenciais](#-diferenciais)
- [Estrutura do projeto](#-estrutura-do-projeto)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação](#-instalação)
- [Desinstalação](#-desinstalação)
- [Scripts e módulos](#-scripts-e-módulos)
- [Segurança e privacidade](#-segurança-e-privacidade-ai-shield)
- [Distros suportadas](#-distros-suportadas)
- [CI e qualidade de código](#-ci-e-qualidade-de-código)
- [Contribuindo](#-contribuindo)
- [Licença](#-licença)

---

## 📖 Sobre o projeto

O **LuminaDev** é uma suíte de automação em Shell Script que transforma uma instalação base do Linux em uma estação de trabalho de alta performance para desenvolvedores PHP/Moodle.

Cada ferramenta é instalada de forma **idempotente** — o script verifica o que já existe antes de agir, nunca sobrescrevendo configurações sem confirmação. O suporte a múltiplas distribuições é gerenciado por um módulo central (`utils.sh`) que detecta automaticamente o package manager disponível.

---

## 🚀 Diferenciais

### 1. AI Shield — Privacidade Nativa

O comando `mygit` gera automaticamente um arquivo `.aiexclude` em cada repositório, impedindo que arquivos sensíveis e binários pesados sejam processados por ferramentas de IA como Claude Code e Gemini Code Assist.

### 2. Experiência Visual "Storm"

Todas as IDEs são configuradas para replicar a ergonomia do ecossistema JetBrains: fonte JetBrains Mono, tema One Dark / JetBrains New UI e atalhos de teclado no padrão IntelliJ IDEA.

### 3. Dual-AI Strategy

Dois ambientes de desenvolvimento paralelos e independentes — VSCode com Claude Code e VSCodium com Gemini Code Assist — permitindo alternar entre ferramentas de IA sem conflito de configurações.

### 4. Idempotência Total

Todos os scripts verificam o estado atual do sistema antes de agir. Reinstalações e execuções repetidas são seguras: o que já está instalado é pulado, e configurações existentes são preservadas com backup antes de qualquer sobrescrita.

### 5. Módulo Utilitário Centralizado

O `utils.sh` provê detecção de distro, funções de verificação e instalação de pacotes compartilhadas por todos os scripts, eliminando duplicação de código e garantindo consistência.

---

## 📂 Estrutura do projeto

```text
lumina-dev/
├── install.sh                  # Menu principal de instalação
├── uninstall.sh                # Menu de remoção seletiva
├── .aiexclude                  # Modelo de bloqueio para ferramentas de IA
├── .gitignore                  # Padrão para projetos PHP/Moodle
│
├── scripts/                    # Utilitários e instaladores de CLI
│   ├── utils.sh                # Módulo central: cores, distro, idempotência
│   ├── fonts-install.sh        # Instalação da JetBrains Mono
│   ├── git-manager.sh          # Core do comando global 'mygit'
│   ├── claude-install.sh       # Instalação do Claude Code CLI
│   └── gemini-install.sh       # Instalação do Gemini Code Assist CLI
│
├── ides/                       # Instaladores de IDEs e editores
│   ├── zed-install.sh          # Zed Editor (uso geral)
│   ├── vscodium-install.sh     # VSCodium — Gemini Edition
│   ├── vscode-install.sh       # VS Code — Claude Edition
│   └── phpstorm-install.sh     # Auxiliar de instalação do PHPStorm (.tar.gz)
│
└── .github/
    └── workflows/
        └── lint.yml            # CI: ShellCheck + Smoke Test
```

---

## ✅ Pré-requisitos

- Linux com `bash` 4.0+
- `sudo` configurado para seu usuário
- Conexão com a internet
- Distro suportada (veja [Distros suportadas](#-distros-suportadas))

Para o instalador do PHPStorm, é necessário baixar o pacote `.tar.gz` manualmente em [jetbrains.com/phpstorm/download](https://www.jetbrains.com/phpstorm/download) antes de executar o script.

---

## 🛠️ Instalação

**1. Clone o repositório:**

```bash
git clone https://github.com/kaduvelasco/lumina-dev.git
cd lumina-dev
```

**2. Dê permissão ao instalador:**

```bash
chmod +x install.sh
```

**3. Execute:**

```bash
./install.sh
```

O menu principal será exibido. As permissões dos demais scripts são sincronizadas automaticamente ao iniciar.

### Opções do menu

| Opção | Descrição                          |
| ----- | ---------------------------------- |
| `1`   | Instalar fontes JetBrains Mono     |
| `2`   | Instalar Git e compilar libsecret  |
| `3`   | Instalar Git Manager (`mygit`)     |
| `4`   | Instalar Claude Code CLI           |
| `5`   | Instalar Gemini Code Assist CLI    |
| `6`   | Instalar Zed Editor                |
| `7`   | Instalar VSCodium (Gemini Edition) |
| `8`   | Instalar VS Code (Claude Edition)  |
| `9`   | Auxiliar de instalação do PHPStorm |
| `0`   | Sair                               |

### Ordem recomendada de instalação

```
1 → Fontes
2 → Git e libsecret
3 → mygit
4 ou 5 → CLI de IA de sua preferência
6, 7, 8 ou 9 → IDE de sua preferência
```

---

## 🧹 Desinstalação

```bash
chmod +x uninstall.sh
./uninstall.sh
```

O menu de remoção permite escolher individualmente o que desinstalar. Cada opção exige confirmação explícita antes de agir.

### Opções do menu

| Opção | Descrição                            |
| ----- | ------------------------------------ |
| `1`   | Remover VS Code (Claude Edition)     |
| `2`   | Remover VSCodium (Gemini Edition)    |
| `3`   | Remover Zed Editor                   |
| `4`   | Remover PHPStorm                     |
| `5`   | Remover comando `mygit`              |
| `6`   | Remover CLIs de IA (Claude / Gemini) |
| `7`   | Remover fontes JetBrains Mono        |
| `0`   | Sair                                 |

---

## 📦 Scripts e módulos

### `scripts/utils.sh`

Módulo central carregado por todos os outros scripts via `source`. Não deve ser executado diretamente.

| Função               | Descrição                                                 |
| -------------------- | --------------------------------------------------------- |
| `detect_pkg_manager` | Detecta e exporta `PKG_MANAGER` (apt / dnf / pacman)      |
| `is_installed_cmd`   | Verifica se um comando existe no PATH                     |
| `is_installed_pkg`   | Verifica se um pacote está instalado                      |
| `is_installed_path`  | Verifica se um arquivo ou diretório existe                |
| `ensure_pkg`         | Instala um pacote apenas se ausente                       |
| `ensure_cmd`         | Retorna 0 se o comando pode ser instalado, 1 se já existe |
| `require_not_root`   | Aborta se executado como root                             |
| `require_sudo`       | Valida que sudo está disponível e funcional               |
| `require_internet`   | Verifica conexão antes de operações de download           |
| `print_section`      | Exibe separador visual com título opcional                |
| `print_version`      | Exibe a versão instalada de um comando                    |

---

### `scripts/git-manager.sh` — comando `mygit`

Instalado globalmente em `/usr/local/bin/mygit` pela opção 3 do `install.sh`. Os placeholders `REPLACE_USER` e `REPLACE_EMAIL` são substituídos pelo instalador via `sed`.

```bash
mygit
```

| Opção | Descrição                                                |
| ----- | -------------------------------------------------------- |
| `1`   | Configurar identidade global do Git                      |
| `2`   | Iniciar novo repositório com `.gitignore` e `.aiexclude` |
| `3`   | Clonar repositório e aplicar identidade local            |
| `4`   | Aplicar identidade e arquivos em repositório existente   |
| `0`   | Sair                                                     |

---

### `scripts/fonts-install.sh`

Instala a **JetBrains Mono v2.304** em `~/.local/share/fonts` e atualiza o cache de fontes do sistema. Verifica se a fonte já está presente antes de baixar.

---

### `scripts/claude-install.sh`

Instala o **Claude Code CLI** via script oficial da Anthropic (`claude.ai/install.sh`). Verifica e instala o Node.js LTS (v18+) se necessário.

**Pós-instalação:** execute `claude` no terminal para autenticar com sua conta Anthropic.

---

### `scripts/gemini-install.sh`

Instala o **Gemini Code Assist CLI** via npm (`@google/gemini-cli`). Verifica e instala o Node.js LTS (v18+) se necessário.

**Pós-instalação:** adicione ao seu shell:

```bash
export GOOGLE_API_KEY='sua_chave_aqui'
```

Gere sua chave em [aistudio.google.com/apikey](https://aistudio.google.com/apikey).

---

### `ides/zed-install.sh`

Instala o **Zed Editor** via script oficial (`zed.dev/install.sh`) e aplica configurações com JetBrains Mono, tema One Dark e suporte a PHP/Moodle.

---

### `ides/vscodium-install.sh` — Gemini Edition

Instala o **VSCodium** via repositório oficial e configura o ambiente completo:

- Extensão: `google.gemini-code-assist`
- Extensões PHP/Moodle: Intelephense, PHP CS Fixer, Moodle Snippets
- Extensões Docker: ms-azuretools.vscode-docker, remote-containers
- Interface: JetBrains Mono, tema JetBrains New UI, keybindings IntelliJ

---

### `ides/vscode-install.sh` — Claude Edition

Instala o **VS Code** via repositório oficial da Microsoft e configura o ambiente completo:

- Extensão: `anthropic.claude-code`
- Extensões PHP/Moodle: idênticas ao VSCodium Edition
- Extensões Docker: idênticas ao VSCodium Edition
- Interface: idêntica ao VSCodium Edition

---

### `ides/phpstorm-install.sh`

Instalador auxiliar para o **PHPStorm** a partir de um pacote `.tar.gz` baixado manualmente. Extrai para `/opt/phpstorm`, cria link simbólico em `/usr/local/bin/phpstorm` e gera entrada `.desktop` no menu do sistema.

> **Atenção:** o PHPStorm requer licença ativa. Baixe em [jetbrains.com/phpstorm](https://www.jetbrains.com/phpstorm/download).

---

## 🛡️ Segurança e Privacidade (AI Shield)

O arquivo `.aiexclude` gerado pelo `mygit` em cada repositório instrui ferramentas de IA a ignorar:

| Categoria            | Arquivos bloqueados                                                                    |
| -------------------- | -------------------------------------------------------------------------------------- |
| **Credenciais**      | `.env`, `*.pem`, `*.key`, `*.p12`, `*.pfx`, `config.php`, `wp-config.php`, `secrets.*` |
| **Dados pesados**    | `/moodledata/`, `/vendor/`, `/node_modules/`                                           |
| **Mídia e binários** | `*.jpg`, `*.png`, `*.gif`, `*.svg`, `*.mp4`, `*.pdf`, `*.zip`, `*.tar.gz`, `*.rar`     |

---

## 🐧 Distros suportadas

| Distro        | Package Manager | Status         |
| ------------- | --------------- | -------------- |
| Ubuntu 22.04+ | apt             | ✅ Suportado   |
| Debian 12+    | apt             | ✅ Suportado   |
| Fedora 39+    | dnf             | ✅ Suportado   |
| Arch Linux    | pacman          | ✅ Suportado   |
| Outras        | —               | ⚠️ Não testado |

> Distribuições baseadas nas acima (Linux Mint, Pop!\_OS, Manjaro etc.) devem funcionar, mas não são oficialmente testadas.

---

## ⚙️ CI e qualidade de código

O workflow `.github/workflows/lint.yml` executa automaticamente a cada push ou pull request na branch `main`.

### Jobs

**ShellCheck** — lint estático em todos os arquivos `.sh` com `--severity=warning`.

**Smoke Test** — valida a sintaxe de cada script com `bash -n`, carrega o `utils.sh` e verifica que todas as funções essenciais estão presentes, além de confirmar que nenhum arquivo obrigatório está faltando na estrutura do projeto.

**Summary** — consolida o resultado dos dois jobs anteriores e falha o workflow se qualquer check não passar.

### Executar localmente

```bash
# Instalar ShellCheck
sudo apt install shellcheck   # Ubuntu/Debian
sudo dnf install ShellCheck   # Fedora
sudo pacman -S shellcheck     # Arch

# Rodar em todos os scripts
find . -name "*.sh" | xargs shellcheck --severity=warning --shell=bash

# Validar sintaxe de um script específico
bash -n scripts/utils.sh
```

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Faça um fork do repositório
2. Crie uma branch: `git checkout -b feature/minha-melhoria`
3. Siga o padrão dos scripts existentes (cabeçalho, `source utils.sh`, idempotência)
4. Certifique-se de que o ShellCheck passa sem warnings: `shellcheck --severity=warning seu-script.sh`
5. Abra um Pull Request descrevendo o que foi alterado

---

## ⚖️ Licença

Este projeto está licenciado sob a [GPL-3.0 License](LICENSE).

---

Feito com ❤️ e IA por [Kadu Velasco](https://github.com/kaduvelasco)

```

```
