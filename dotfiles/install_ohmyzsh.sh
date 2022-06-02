#!/bin/bash

source "${BASH_SOURCE%/*}/inc/funcs.sh"
OHMYZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"

print_info "Installing oh-my-zsh..." && sleep 2
git clone -q --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "${OHMYZSH_DIR}"
