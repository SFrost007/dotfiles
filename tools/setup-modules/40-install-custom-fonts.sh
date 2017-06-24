#!/bin/bash

_module_friendlyname() {
  echo "Install custom fonts for IDEs/Terminal"
}

_module_run_after_git_pull() {
  return 0 # YES
}

_module_valid() {
  # TODO: Scan fonts dir and check whether everything exists
  return 0 # YES (Always valid)
}

_module_exec() {
  local FONTS_DIR
  case `get_platform` in
    $PLATFORM_OSX) FONTS_DIR="$HOME/Library/Fonts";;
    $PLATFORM_LINUX) FONTS_DIR="$HOME/.local/share/fonts";;
  esac
  mkdir -p $FONTS_DIR
  cp -r ./fonts/* $FONTS_DIR && success "Fonts installed" || warn "Error installing fonts"
}
