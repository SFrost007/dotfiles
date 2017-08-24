#!/bin/bash

_CORE_TOOLS=(git vim tmux curl tree wget zsh)

_module_friendlyname() {
  echo "Install Core Tools"
}

_module_run_after_git_pull() {
  return 1 # NO
}

_module_valid() {
  if [[ "$(get_platform)" != "${PLATFORM_OSX}" ]]; then
    if ! check_command_exists "brew"; then return 1; fi
  fi
  for i in "${_CORE_TOOLS}"; do
    if ! check_command_exists "$i"; then return 0; fi
  done
  return 1 # Everything already exists.
}

_module_coretools_install() {
  case `get_platform` in
    $PLATFORM_LINUX)
      sudo apt-get install $1 ;;
    $PLATFORM_OSX)
      brew install $1 ;;
  esac
}

_module_exec() {
  for i in "${_CORE_TOOLS}"; do
    if ! check_command_exists "$i"; then
      _module_coretools_install "$i"
    fi
  done
}
