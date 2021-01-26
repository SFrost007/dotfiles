#!/bin/sh
#
# Installs Homebrew (using their curl install script) if not already present,
# and taps the cask-versions repo.

source "${BASH_SOURCE%/*}/../inc/funcs.sh"

if command_exists "brew"; then
  print_success "Homebrew already installed"
else
  print_info "Installing Homebrew..." && sleep 2
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew tap homebrew/cask-versions
  printf "\n\n"
fi
