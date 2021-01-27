#!/bin/sh

source "${BASH_SOURCE%/*}/inc/funcs.sh"

_main() {
  for FONT_PATH in ${DOTFILES_DIR}/fonts/*; do
    install_font "${FONT_PATH}"
  done
}

install_font() {
  local FONTS_DIR

  local FONT_NAME=$(basename "${1}")
  if is_mac; then
    FONTS_DIR="$HOME/Library/Fonts"
  elif is_linux; then
    FONTS_DIR="$HOME/.fonts"
  elif is_win; then
    FONTS_DIR="/mnt/c/Windows/Fonts"
  else
    print_warning "Skipping font installation for unknown platform"
  fi
  
  if file_exists "${FONTS_DIR}/${FONT_NAME}"; then
    print_success "${FONT_NAME} already installed"
  else
    mkdir -p "${FONTS_DIR}"
    cp "${1}" "${FONTS_DIR}"
    if file_exists "${FONTS_DIR}/${FONT_NAME}"; then
      print_success "Installed font ${FONT_NAME}"
    else
      print_error "Error installing font ${FONT_NAME}"
    fi
  fi
}

_main
