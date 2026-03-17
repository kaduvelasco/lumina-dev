# 💡 LuminaDev - Elite Workstation Setup

O **LuminaDev** é uma suíte de automação projetada para transformar uma instalação base do Linux em uma estação de trabalho de alta performance, otimizada para desenvolvedores PHP/Moodle e blindada para o uso de Inteligência Artificial.

## 📂 Estrutura do Projeto

```text
lumina-dev/
├── install.sh             # Menu principal de instalação
├── scripts/               # Scripts de suporte e utilitários
│   ├── fonts-install.sh   # Instalação de JetBrains Mono
│   ├── git-manager.sh     # O core do comando 'mygit'
│   ├── claude-install.sh  # Setup do Claude Code CLI
│   └── gemini-install.sh  # Setup do Gemini Code Assist CLI
└── ides/                  # Scripts de instalação de IDEs
    ├── zed-install.sh     # Editor Zed (Geral)
    ├── vscodium-install.sh # VSCodium (Gemini Edition)
    ├── vscode-install.sh   # VSCode (Claude Edition)
    └── phpstorm-install.sh # Auxiliar para PHPStorm (.tar.gz)
```

# 🚀 Diferenciais do LuminaDev

1. IA Shield (Privacidade Nativa)

Diferente de setups comuns, o **LuminaDev** foca na segurança do seu código ao utilizar LLMs. Através do comando `mygit`, ele gera automaticamente o `.aiexclude`, impedindo que arquivos sensíveis (como `config.php`) e binários pesados sejam processados por IAs externas.

2. Experiência Visual "Storm"

Todas as IDEs são configuradas para replicar a ergonomia e produtividade do ecossistema JetBrains, unindo a leveza de editores modernos com a memória muscular de ferramentas profissionais.

3. Orquestração de Permissões

O `install.sh` atua como um gerenciador inteligente: ao ser iniciado, ele sincroniza recursivamente as permissões de execução de todos os módulos do projeto.

# 🚀 Principais funcionalidades

1. Central de Instalação (`install.sh`)

Um menu interativo que gerencia todo o ambiente:

- **Automação de Permissões:** Ao ser iniciado, o install.sh concede automaticamente permissão de execução a todos os scripts das pastas scripts/ e ides/.

- **Injeção de Identidade:** Durante a instalação do mygit, o instalador solicita seu nome e e-mail e os injeta diretamente no binário final, mantendo o código-fonte limpo de dados pessoais.

- **Git & Segurança:** Compilação do libsecret para persistência de credenciais.

- **IDEs Customizadas:** Setup de ambientes que replicam a experiência do PHPStorm (atalhos, temas e fontes).

2. MyGit (`mygit`)

Um comando global instalado em `/usr/local/bin/mygit` que automatiza o dia a dia do desenvolvedor:

- **Identidade Dinâmica:** Alterna entre perfis de usuário/e-mail configurados na instalação.

- **Proteção IA Nativa:** Gera arquivos `.aiexclude` para impedir que dados sensíveis (como `config.php`, `.env` e chaves `.pem`) e arquivos binários pesados sejam enviados para processamento de LLMs.

- **Padronização:** Cria `.gitignore` otimizado para ecossistemas Moodle e Web.

# 🛠️ Como Usar

Dar permissão de execução ao instalador:

1. Clonar o repositório e entrar na pasta:

```bash
git clone [https://github.com/kaduvelasco/lumina-dev.git](https://github.com/kaduvelasco/lumina-dev.git)
cd lumina-dev
```

2. Dar permissão para o instalador:

```bash
chmod +x install.sh
```

Iniciar a instalação:

```bash
./install.sh
```

## 🧹 Desinstalação

Caso precise remover alguma ferramenta ou limpar o ambiente, o **LuminaDev** oferece um utilitário dedicado:

1. **Executar o desinstalador:**

```bash
chmod +x uninstall.sh
./uninstall.sh
```

O menu permite escolher individualmente quais IDEs, CLIs de IA ou comandos globais (como o mygit) você deseja remover do sistema de forma limpa.

# 🛡️ Segurança e Privacidade (AI-Ready)

O projeto foi desenhado para o uso seguro de LLMs (Claude/Gemini). O arquivo `.aiexclude` gerado automaticamente bloqueia:

- **Segurança:** .env, \*.pem, config.php.

- **Performance:** vendor/, node_modules/, moodledata/.

- **Economia de Tokens:** Bloqueio de mídias (.jpg, .mp4, .pdf, etc).

# 🎨 Experiência visual

Todas as IDEs instaladas através desta central são configuradas para:

- **Fonte:** JetBrains Mono (Size 14, Line Height 1.6).

- **Tema:** JetBrains New UI / One Dark.

- **Keybindings:** Padrão IntelliJ IDEA.

# ⚖️ Licença

Este projeto está licenciado sob a GPL-3.0 License. Veja o arquivo `LICENSE` para mais detalhes.

---

Feito com ❤️ e IA por Kadu Velasco
