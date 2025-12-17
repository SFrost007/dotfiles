#!/bin/sh

source "${BASH_SOURCE%/*}/../inc/funcs.sh"

GEMS=(
)

if is_mac; then
  GEMS+=(
    xcodeproj
    xcpretty
  )
fi


_main() {
  title "Installing Ruby Gem packages..."
  if command_exists "gem"; then
    for gem_pkg in ${GEMS[@]}; do
      install_gem $gem_pkg
    done
  else
    print_warning "Skipping Ruby Gems as gem isn't installed"
  fi
}

install_gem() {
  if gem list "$1" --installed > /dev/null; then
    print_success "$1 already installed"
  else
    gem install "$1"
    print_success "Installed $1"
  fi
}

_main
