#!/bin/bash

_module_friendlyname() {
  echo "Remove git hook when changes are pulled"
}

_module_run_after_git_pull() {
  return 1 # NO
}

_module_valid() {
  if check_file_exists "$DOTFILES_DIR/.git/hooks/post-merge"; then
    return 0 # Installed
  fi
  return 1 # Not installed
}

_module_exec() {
  rm ${DOTFILES_DIR}/.git/hooks/post-merge
}
