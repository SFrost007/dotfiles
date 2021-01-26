#!/bin/sh

source "${BASH_SOURCE%/*}/../inc/funcs.sh"

NPM_PACKAGES=(
  # General tools
  diff-so-fancy
  # Web development
  express-generator
  mongodb
  typescript
)

_main() {
  title "Installing NPM packages..."
  if command_exists "npm"; then
    for pkg in ${NPM_PACKAGES[@]}; do
      install_npm $pkg
    done
  else
    print_warning "Skipping NPM packages as npm isn't installed"
  fi
}

install_npm() {
  if dir_exists "$(npm config get prefix)/lib/node_modules/$1"; then
    print_success "$1 already installed"
  elif [[ $(npm list -g --depth=0 --parseable | grep -e "/${1}$") ]]; then
    print_success "$1 already installed"
  else
    print_info "Installing $1..."
    if [[ $(npm install -g --no-progress $1) ]]; then
      print_success "Installed $1"
    else
      print_error "Error installing $1"
    fi
  fi
}

_main
