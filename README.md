# Neovim Configuration Setup

This is a comprehensive Neovim configuration with LSP, formatting, linting, and debugging support for multiple languages.

## Prerequisites

Before setting up this Neovim configuration, make sure you have the following installed:

### Required Software

1. **Neovim** (>= 0.9.0)
   ```bash
   # macOS
   brew install neovim
   
   # Ubuntu/Debian
   sudo apt install neovim
   
   # Arch Linux
   sudo pacman -S neovim
   ```

2. **Node.js** (>= 16.0.0) - Required for most language servers
   ```bash
   # macOS
   brew install node
   
   # Ubuntu/Debian
   curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
   sudo apt-get install -y nodejs
   
   # Or use nvm for version management
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
   nvm install --lts
   ```

3. **Python 3** - Required for Python linting and some tools
   ```bash
   # macOS (usually pre-installed)
   brew install python3
   
   # Ubuntu/Debian
   sudo apt install python3 python3-pip
   ```

4. **Go** (optional, for Go development)
   ```bash
   # macOS
   brew install go
   
   # Ubuntu/Debian
   sudo apt install golang-go
   ```

5. **Git** - For version control and plugin management
   ```bash
   # macOS
   brew install git
   
   # Ubuntu/Debian
   sudo apt install git
   ```

### Development Tools

6. **.NET SDK** (optional, for C# development)
   ```bash
   # macOS
   brew install dotnet
   
   # Ubuntu/Debian
   # Follow instructions from: https://docs.microsoft.com/en-us/dotnet/core/install/linux
   ```

7. **Rust** (optional, for some fast tools)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

### Essential CLI Tools (Required for full functionality)

8. **ripgrep** - Fast text search (required for Telescope live grep)
   ```bash
   # macOS
   brew install ripgrep
   
   # Ubuntu/Debian
   sudo apt install ripgrep
   
   # Arch Linux
   sudo pacman -S ripgrep
   ```

9. **fd** - Fast file finder (recommended for Telescope file search)
   ```bash
   # macOS
   brew install fd
   
   # Ubuntu/Debian
   sudo apt install fd-find
   
   # Arch Linux
   sudo pacman -S fd
   ```

10. **fzf** - Fuzzy finder (required for telescope-fzf-native)
    ```bash
    # macOS
    brew install fzf
    
    # Ubuntu/Debian
    sudo apt install fzf
    
    # Arch Linux
    sudo pacman -S fzf
    ```

11. **make** - Build system (required for compiling telescope-fzf-native)
    ```bash
    # macOS (install Xcode command line tools)
    xcode-select --install
    
    # Ubuntu/Debian
    sudo apt install build-essential
    
    # Arch Linux
    sudo pacman -S base-devel
    ```

### Language-specific Tools

12. **TypeScript** (global installation recommended for Angular development)
    ```bash
    npm install -g typescript
    ```

13. **Angular CLI** (optional, for Angular development)
    ```bash
    npm install -g @angular/cli
    ```

## Installation Steps

1. **Clone this configuration to your Neovim config directory:**
   ```bash
   # Backup existing config (if any)
   mv ~/.config/nvim ~/.config/nvim.backup
   
   # Clone this repository
   git clone <your-repo-url> ~/.config/nvim
   ```

2. **Make wrapper scripts executable:**
   ```bash
   chmod +x ~/.config/nvim/bin/*
   ```

3. **First Neovim startup:**
   ```bash
   nvim
   ```
   
   On first startup, the configuration will:
   - Install Lazy.nvim (plugin manager)
   - Download and install all plugins
   - Install Mason tools (LSP servers, formatters, linters)
   
   This may take a few minutes. Wait for all installations to complete.

4. **Verify Mason installations:**
   
   Open Neovim and run:
   ```vim
   :Mason
   ```
   
   You should see all these tools installed:
   - **Language Servers:** lua-language-server, typescript-language-server, angular-language-server, json-lsp, yaml-language-server, svelte-language-server, gopls, csharp-language-server
   - **Formatters:** prettier, stylua, isort, black
   - **Linters:** eslint_d, pylint
   - **Debug Adapters:** chrome-debug-adapter

## Installed Tools and Their Purposes

### Language Servers (LSP)
- **lua-language-server**: Lua language support
- **typescript-language-server**: TypeScript/JavaScript support
- **angular-language-server**: Angular framework support
- **json-lsp**: JSON file support
- **yaml-language-server**: YAML file support
- **svelte-language-server**: Svelte framework support
- **gopls**: Go language support
- **csharp-language-server**: C# language support

### Formatters
- **prettier**: JavaScript, TypeScript, JSON, YAML, HTML, CSS, Markdown formatting
- **stylua**: Lua code formatting

### Linters
- **eslint_d**: Fast JavaScript/TypeScript linting
- **pylint**: Python code linting

### Debug Adapters
- **chrome-debug-adapter**: Debug JavaScript/TypeScript in Chrome

## Key Features

- **LSP Support**: Full language server protocol support with auto-completion, diagnostics, and code actions
- **Auto-formatting**: Format on save for supported file types
- **Linting**: Real-time code linting and error detection
- **Telescope**: Fuzzy finder for files, grep, and more
- **Harpoon**: Quick file navigation
- **Oil.nvim**: File explorer
- **Treesitter**: Syntax highlighting and code parsing
- **GitHub Copilot**: AI-powered code completion
- **Undotree**: Visual undo history
- **Which-key**: Keybinding hints

## Key Mappings

The configuration uses `<leader>` as the main prefix (default is space).

- `<leader>pv`: Open file explorer (Oil)
- `<leader>pf`: Find files (Telescope)
- `<leader>ps`: Live grep (Telescope)
- `<leader>vh`: Open harpoon menu
- `<leader>a`: Add file to harpoon
- `<C-h>`, `<C-t>`, `<C-n>`, `<C-s>`: Navigate harpoon files
- `<leader>u`: Open undotree
- `<leader>f`: Format current file/selection
- `<leader>l`: Trigger linting

## Troubleshooting

### LSP servers not working
1. Check Mason installation: `:Mason`
2. Check LSP status: `:LspInfo`
3. Restart LSP: `:LspRestart`

### Formatters not working
1. Check if prettier/stylua are installed in Mason
2. Check conform configuration: `:ConformInfo`

### Angular development setup
The configuration includes a hardcoded path for Angular LSP. Update the path in `lua/matias/lazy/lsp.lua` to match your Node.js installation:
```lua
local project_root = "/path/to/your/node/installation/lib"
```

### Missing wrapper scripts
If you encounter errors about missing wrapper scripts, ensure they are executable:
```bash
chmod +x ~/.config/nvim/bin/*
```

## Updating

To update the configuration:
1. Pull latest changes: `git pull`
2. Update plugins: Open Neovim and run `:Lazy sync`
3. Update Mason tools: `:MasonToolsUpdate`

## File Structure

```
~/.config/nvim/
├── init.lua                    # Main configuration entry point
├── lazy-lock.json              # Plugin version lock file
├── lua/
│   ├── matias/
│   │   ├── init.lua            # Main module loader
│   │   ├── lazy_init.lua       # Lazy.nvim setup
│   │   └── lazy/               # Individual plugin configurations
│   ├── colorscheme.lua         # Color scheme settings
│   ├── mappings.lua            # Key mappings
│   └── set.lua                 # Neovim settings
├── bin/                        # Wrapper scripts
│   ├── csharp-ls-wrapper
│   ├── typescript-language-server-quiet
│   └── vscode-json-language-server-quiet
└── README.md                   # This file
```

## Customization

To customize this configuration:
1. Plugin configurations are in `lua/matias/lazy/`
2. General settings are in `lua/set.lua`
3. Key mappings are in `lua/mappings.lua`
4. Color scheme is set in `lua/colorscheme.lua`

## Support

This configuration is tailored for full-stack development with focus on:
- TypeScript/JavaScript (React, Angular, Svelte)
- Go
- C#
- Python
- Lua
- JSON/YAML configuration files

For language-specific issues, check the corresponding LSP server documentation and Mason installation status.
