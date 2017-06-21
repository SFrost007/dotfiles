#!/bin/bash

_module_friendlyname() {
  echo "Install homebrew"
}

_module_run_after_git_pull() {
  return 1 # NO
}

_module_valid() {
  if [[ $(get_platform) -ne "${PLATFORM_OSX}" ]]; then
    return 1; # Wrong OS
  elif check_command_exists "brew"; then
    return 1 # Already installed
  elif ! check_command_exists "ruby"; then
    return 1 # Cannot install
  elif ! check_command_exists "curl"; then
    return 1 # Cannot install
  fi
  return 0 # Ok to install
}

_module_exec() {
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}
