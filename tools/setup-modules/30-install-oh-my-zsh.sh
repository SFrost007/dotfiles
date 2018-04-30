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
  elif ! check_command_exists "zsh"; then
    return 1 # Cannot install without zsh
  fi
  return 0 # Ok to install
}

_module_exec() {
  check_command_exists "zsh" || fail "ZSH must be installed to install oh-my-zsh"

  local TARGET_DIR="${HOME}/.oh-my-zsh"
  info "Cloning oh-my-zsh to $TARGET_DIR"
  git clone -q --depth=1 https://github.com/robbyrussell/oh-my-zsh.git "${TARGET_DIR}" \
    || fail "Failed to clone oh-my-zsh"

  info "Setting ZSH as default shell"
  chsh -s $(grep /zsh$ /etc/shells | tail -1)

  printf "${_GREEN}"
  echo '         __                                     __   '
  echo '  ____  / /_     ____ ___  __  __   ____  _____/ /_  '
  echo ' / __ \/ __ \   / __ `__ \/ / / /  /_  / / ___/ __ \ '
  echo '/ /_/ / / / /  / / / / / / /_/ /    / /_(__  ) / / / '
  echo '\____/_/ /_/  /_/ /_/ /_/\__, /    /___/____/_/ /_/  '
  echo '                        /____/                       ....is now installed!'
  echo ''
  printf "${_RESET}"
}
