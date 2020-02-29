#!/bin/sh

VSCODE_USER_DIR="${HOME}/Library/Application Support/Code/User"
mkdir -p "${VSCODE_USER_DIR}"

# TODO: Check if these already exist, skip if they do
ln -s "${DOTFILES_DIR}/VSCode/settings.json" "${VSCODE_USER_DIR}/settings.json"
ln -s "${DOTFILES_DIR}/VSCode/keybindings.json" "${VSCODE_USER_DIR}/keybindings.json"
ln -s "${DOTFILES_DIR}/VSCode/snippets/" "${VSCODE_USER_DIR}"

code --install-extension Dart-Code.flutter
