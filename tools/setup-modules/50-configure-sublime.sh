#!/bin/bash

_module_friendlyname() {
  echo "Configure Sublime plugins"
}

_module_run_after_git_pull() {
  return 1 # NO
}

_module_valid() {
  if [[ "$(get_platform)" == "${PLATFORM_WSL}" ]]; then
    return 1 # TODO: Support Windows appdata dir outside WSL
  fi

  # TODO: Remove this duplication
  local SUBLIME_DIR
  case `get_platform` in
    $PLATFORM_OSX) SUBLIME_DIR="$HOME/Library/Application Support/Sublime Text 3";;
    $PLATFORM_LINUX) SUBLIME_DIR="$HOME/.config/sublime-text-3";;
  esac

  if [[ -d "${SUBLIME_DIR}/Packages/User" ]]; then
    return 1 # Already installed
  fi

  return 0
}

_module_exec() {
  local SUBLIME_DIR
  case `get_platform` in
    $PLATFORM_OSX) SUBLIME_DIR="$HOME/Library/Application Support/Sublime Text 3";;
    $PLATFORM_LINUX) SUBLIME_DIR="$HOME/.config/sublime-text-3";;
  esac

  # Auto-install Package Control
  INSTALLED_PKG_DIR="${SUBLIME_DIR}/Installed Packages"
  if [[ ! -f "${INSTALLED_PKG_DIR}/Package Control.sublime-package" ]]; then
    mkdir -p "${INSTALLED_PKG_DIR}"
    pushd "${INSTALLED_PKG_DIR}" > /dev/null
    wget http://sublime.wbond.net/Package%20Control.sublime-package -o /dev/null
    if [[ $? -eq 0 ]]; then
      success 'Installed Package Control for Sublime'
    else
      fail 'Failed to download Package Control'
    fi
    popd > /dev/null
  else
    success 'Skipped installing Package Control - already exists'
  fi

  # Link our dotfiles
  PACKAGES_DIR="${SUBLIME_DIR}/Packages"
  mkdir -p "${PACKAGES_DIR}"
  ln -s "${HOME}/.dotfiles/sublime/" "${PACKAGES_DIR}/User"
  success "Sublime config files configured"
}
