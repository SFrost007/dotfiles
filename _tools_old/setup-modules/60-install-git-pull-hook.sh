#!/bin/bash

_module_friendlyname() {
  echo "Setup git hook to re-run installer whenever changes are pulled"
}

_module_run_after_git_pull() {
  return 1 # NO
}

_module_valid() {
  if check_file_exists "$DOTFILES_DIR/.git/hooks/post-merge"; then
    return 1 # Already installed
  fi
  return 0 # Ok to install
}

_module_exec() {
  ln -s ${DOTFILES_DIR}/tools/install.sh ${DOTFILES_DIR}/.git/hooks/post-merge
}
