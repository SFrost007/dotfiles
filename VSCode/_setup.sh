#!/bin/sh

if hash figlet 2>/dev/null; then
    figlet -f "Small Slant" "VSCode Setup"
else
  echo "VSCode Setup\n============\n"
fi

VSCODE_USER_DIR="${HOME}/Library/Application Support/Code/User"
mkdir -p "${VSCODE_USER_DIR}"

echo "Linking config files..."
# TODO: Check if these already exist, skip if they do
ln -s "${DOTFILES_DIR}/VSCode/settings.json" "${VSCODE_USER_DIR}/settings.json"
ln -s "${DOTFILES_DIR}/VSCode/keybindings.json" "${VSCODE_USER_DIR}/keybindings.json"
ln -s "${DOTFILES_DIR}/VSCode/snippets/" "${VSCODE_USER_DIR}"
echo ""

# General
code --install-extension eamodio.gitlens
code --install-extension earshinov.filter-lines
code --install-extension usernamehw.errorlens
code --install-extension anthropic.claude-code
code --install-extension shd101wyy.markdown-preview-enhanced
