#!/bin/bash

_module_friendlyname() {
  echo "Install oh-my-zsh"
}

_module_run_after_git_pull() {
  return 1 # NO
}

_module_valid() {
  if check_dir_exists "$HOME/.oh-my-zsh"; then
    return 1 # Already installed
  elif ! check_command_exists "curl"; then
    return 1 # Cannot install
  fi
  return 0 # Ok to install
}

_module_exec() {
  # TODO: Extract the minimal commands based on knowledge of prior setup?
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  # TODO: Move these to regular submodule clones in .dotfiles/zsh/omz-custom,
  # and symlink from there
  git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
}
