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
code --install-extension CoenraadS.bracket-pair-colorizer-2
code --install-extension eamodio.gitlens
code --install-extension auchenberg.vscode-browser-preview
code --install-extension hediet.vscode-drawio
code --install-extension usernamehw.errorlens
# Themes
code --install-extension zhuangtongfa.material-theme
# Javascript
code --install-extension msjsdiag.vscode-react-native
# Dart
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
# Ruby
code --install-extension bung87.rails
code --install-extension bung87.vscode-gemfile
code --install-extension rebornix.ruby
code --install-extension sianglim.slim
code --install-extension wingrunr21.vscode-ruby
# Docker
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-vscode-remote.remote-containers

