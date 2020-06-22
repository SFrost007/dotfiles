#!/bin/zsh
# Script to test replacing oh-my-zsh with manual plugin loading. Not actively used.

PLUGINS_DIR="${HOME}/.dotfiles/zsh/omz-custom/plugins"
source "${PLUGINS_DIR}/alias-tips/alias-tips.plugin.zsh"
source "${PLUGINS_DIR}/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
source "${PLUGINS_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"

builtin_plugins=(
  colored-man-pages
  encode64
  urltools
  xcode
  z
)
OMZ_PLUGINS_DIR="${HOME}/.oh-my-zsh/plugins"
for i in $builtin_plugins; do
  source "${OMZ_PLUGINS_DIR}/${i}/${i}.plugin.zsh"
done


source "${HOME}/.dotfiles/zsh/omz-custom/powerlevel9k/powerlevel9k.zsh-theme"
