#!/bin/bash

_module_friendlyname() {
  echo "Configure Sublime plugins"
}

_module_run_after_git_pull() {
  return 1 # NO
}

_module_valid() {
  # TODO: Check for presence of sublime packages dir and whether it's a symlink
  return 1
}

_module_exec() {
  # TODO: Check over and enable this
  echo "Ran configure-sublime"
  #local overwrite_all=false backup_all=false skip_all=false
  #$(./scripts/AssertOSX);
  #if [[ $? -eq 0 ]]; then
  #  SUBLIME_DIR=${HOME}/Library/Application\ Support/Sublime\ Text\ 2
  #else
  #  SUBLIME_DIR=${HOME}/.config/sublime-text-2
  #fi
  #
  #mkdir -p "${SUBLIME_DIR}/Packages"
  #link_file "${DOTFILES_ROOT}/sublime/" "${SUBLIME_DIR}/Packages/User"
  #
  #if [[ ! -f "${SUBLIME_DIR}/Installed Packages/Package Control.sublime-package" ]]; then
  #  mkdir -p "${SUBLIME_DIR}/Installed Packages"
  #  pushd "${SUBLIME_DIR}/Installed Packages" > /dev/null
  #  wget http://sublime.wbond.net/Package%20Control.sublime-package -o /dev/null
  #  if [[ $? -eq 0 ]]; then
  #    success 'Installed Package Control for Sublime'
  #  else
  #    fail 'Failed to download Package Control'
  #  fi
  #  popd > /dev/null
  #else
  #  success 'Skipped installing Package Control - already exists'
  #fi
}
