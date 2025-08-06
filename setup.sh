#!/usr/bin/env bash

# Neovim Configuration Setup Script
set -e

echo "🚀 Setting up Neovim configuration..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    local missing_deps=()
    
    if ! command_exists nvim; then
        missing_deps+=("neovim")
    fi
    
    if ! command_exists node; then
        missing_deps+=("node.js")
    fi
    
    if ! command_exists git; then
        missing_deps+=("git")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_status "Please install the missing dependencies and run this script again."
        print_status "See README.md for installation instructions."
        exit 1
    fi
    
    print_success "All required dependencies are installed!"
}

# Make wrapper scripts executable
setup_wrappers() {
    print_status "Setting up wrapper scripts..."
    
    local config_dir="$HOME/.config/nvim"
    local bin_dir="$config_dir/bin"
    
    if [ -d "$bin_dir" ]; then
        chmod +x "$bin_dir"/*
        print_success "Wrapper scripts made executable"
    else
        print_warning "Wrapper scripts directory not found"
    fi
}

# Check Neovim version
check_neovim_version() {
    print_status "Checking Neovim version..."
    
    local nvim_version=$(nvim --version | head -n1 | sed 's/NVIM v\([0-9.]*\).*/\1/')
    local required_version="0.9.0"
    
    if [ "$(printf '%s\n' "$required_version" "$nvim_version" | sort -V | head -n1)" = "$required_version" ]; then
        print_success "Neovim version $nvim_version is compatible"
    else
        print_error "Neovim version $nvim_version is too old. Please upgrade to $required_version or newer."
        exit 1
    fi
}

# Initial Neovim setup
initial_nvim_setup() {
    print_status "Starting initial Neovim setup..."
    print_status "This will install Lazy.nvim and all plugins..."
    print_status "Please wait, this may take a few minutes..."
    
    # Run Neovim headless to install plugins
    nvim --headless -c "qall" 2>/dev/null || true
    
    print_success "Initial Neovim setup completed!"
}

# Show next steps
show_next_steps() {
    echo ""
    print_success "Setup completed successfully! 🎉"
    echo ""
    print_status "Next steps:"
    echo "  1. Start Neovim: nvim"
    echo "  2. Wait for Mason to install language servers (first startup only)"
    echo "  3. Check Mason status: :Mason"
    echo "  4. Check LSP status: :LspInfo"
    echo ""
    print_status "Key mappings (leader = space):"
    echo "  <leader>pf  - Find files"
    echo "  <leader>ps  - Live grep"
    echo "  <leader>pv  - File explorer"
    echo "  <leader>f   - Format file"
    echo "  <leader>l   - Lint file"
    echo ""
    print_status "For more information, see README.md"
}

# Check essential CLI tools
check_cli_tools() {
    print_status "Checking essential CLI tools..."
    
    local cli_tools=("rg" "fd" "fzf" "make")
    local missing_tools=()
    local available_tools=()
    
    for tool in "${cli_tools[@]}"; do
        if command_exists "$tool"; then
            available_tools+=("$tool")
        else
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#available_tools[@]} -gt 0 ]; then
        print_success "Available CLI tools: ${available_tools[*]}"
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        print_warning "Missing CLI tools: ${missing_tools[*]}"
        print_status "Some features may not work without these tools:"
        
        for tool in "${missing_tools[@]}"; do
            case $tool in
                "rg")
                    echo "  - ripgrep (rg): Required for Telescope live grep"
                    ;;
                "fd")
                    echo "  - fd: Recommended for faster file finding in Telescope"
                    ;;
                "fzf")
                    echo "  - fzf: Required for telescope-fzf-native plugin"
                    ;;
                "make")
                    echo "  - make: Required to compile telescope-fzf-native"
                    ;;
            esac
        done
        echo ""
        print_status "Install missing tools using your package manager (brew, apt, pacman, etc.)"
    fi
}

# Check for optional dependencies
check_optional_deps() {
    print_status "Checking optional dependencies..."
    
    local optional_deps=("go" "python3" "dotnet" "typescript")
    local available_deps=()
    local missing_deps=()
    
    # Check regular commands
    for dep in "go" "python3" "dotnet"; do
        if command_exists "$dep"; then
            available_deps+=("$dep")
        else
            missing_deps+=("$dep")
        fi
    done
    
    # Check TypeScript separately (it's an npm package)
    if command_exists "tsc"; then
        available_deps+=("typescript")
    else
        missing_deps+=("typescript")
    fi
    
    if [ ${#available_deps[@]} -gt 0 ]; then
        print_success "Available optional dependencies: ${available_deps[*]}"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_warning "Missing optional dependencies: ${missing_deps[*]}"
        print_status "Some language features may not work without these dependencies:"
        
        for dep in "${missing_deps[@]}"; do
            case $dep in
                "go")
                    echo "  - Go: Required for Go language support"
                    ;;
                "python3")
                    echo "  - Python 3: Required for Python linting and formatting"
                    ;;
                "dotnet")
                    echo "  - .NET SDK: Required for C# development"
                    ;;
                "typescript")
                    echo "  - TypeScript: Required for Angular development (install with: npm install -g typescript)"
                    ;;
            esac
        done
    fi
}

# Main setup function
main() {
    echo "┌─────────────────────────────────────────┐"
    echo "│        Neovim Configuration Setup       │"
    echo "└─────────────────────────────────────────┘"
    echo ""
    
    check_prerequisites
    check_neovim_version
    check_cli_tools
    check_optional_deps
    setup_wrappers
    initial_nvim_setup
    show_next_steps
}

# Run main function
main "$@"
