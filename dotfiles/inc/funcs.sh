#!/bin/sh

# TODO: These ideally shouldn't be repeated from install.sh
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
export DOTFILES_TOOLS_DIR="${DOTFILES_DIR}/dotfiles"

################################################################################
# Print handlers
################################################################################

bold=$(tput bold)
normal=$(tput sgr0)

_print_in_color() {
    printf "%b" \
        "$(tput setaf "$2" 2> /dev/null)" \
        "$1" \
        "$(tput sgr0 2> /dev/null)"
}

_print_in_red() {
  _print_in_color "$1" 1
}

_print_in_green() {
    _print_in_color "$1" 2
}

_print_in_yellow() {
    _print_in_color "$1" 3
}

_print_in_blue() {
    _print_in_color "$1" 4
}

_print_in_purple() {
    _print_in_color "$1" 5
}

_print_in_cyan() {
    _print_in_color "$1" 6
}

_print_in_white() {
    _print_in_color "$1" 7
}

title_count="${title_count:-1}"
title() {
  local fmt="$1"; shift
  printf "
✦  ${bold}$((title_count++)). $fmt${normal}
└──────────────────────────────────────────────────────────────────────────────○
" "$@"
}

print_success() {
  _print_in_green "[✓] $1\n"
}

print_error() {
  _print_in_red "[X] $1\n"
}

print_warning() {
  _print_in_yellow "/!\ $1\n"
}

print_info() {
  printf "[i] $1\n"
}

print_deleted() {
  print_warning "$1"
}

print_waiting() {
  printf "... Press enter to continue...\n"
  read
}

print_if_skipped() {
  if [[ $1 -gt 0 ]]; then
    print_info "Skipped ${1} existing ${2}"
  fi
}

exit_with_message() {
  print_error "$1\n" && exit 1
}

################################################################################
# Prompts
################################################################################

ask() {
  local reply

  # Workaround to detect whether we need -n or \c to prevent newline on echo
  # https://www.shellscript.sh/tips/echo/
  if [ "`echo -n`" = "-n" ]; then
    n=""
    c="\c"
  else
    n="-n"
    c=""
  fi

  while true; do
    echo $n "[?] $1 [y/n] $c"
    read reply </dev/tty
    case "$reply" in
      Y*|y*) return 0 ;;
      N*|n*) return 1 ;;
    esac
  done
}

ask_for_sudo() { # https://gist.github.com/cowboy/3118588
    sudo -v &> /dev/null
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    print_success "Password cached"
}

################################################################################
# Existence checks
################################################################################

file_exists() {
  if [ -e "${1}" ]; then return 0; else return 1; fi
}

dir_exists() {
  if [ -d "${1}" ]; then return 0; else return 1; fi;
}

command_exists() {
  type $1 >/dev/null 2>&1 || return 1; return 0;
}

################################################################################
# "Computer type" checks for value stored in _DOTFILES_COMPTYPE variable
################################################################################

_COMPTYPE_HOME="Home"
_COMPTYPE_WORK="Work"
_COMPTYPE_FILE="${DOTFILES_TOOLS_DIR}/.computertype"

load_computer_type() {
  if file_exists "${_COMPTYPE_FILE}"; then
    source "${_COMPTYPE_FILE}"
  fi
}

prompt_for_computer_type_if_not_set() {
  load_computer_type
  if [ -z ${_DOTFILES_COMPTYPE} ]; then
    if ask "Is this a home [y] or work [n] computer?"; then
      echo "_DOTFILES_COMPTYPE=${_COMPTYPE_HOME}" > "${_COMPTYPE_FILE}"
    else
      echo "_DOTFILES_COMPTYPE=${_COMPTYPE_WORK}" > "${_COMPTYPE_FILE}"
    fi
  fi
}

print_computer_type() {
  load_computer_type
  if [ -z ${_DOTFILES_COMPTYPE} ]; then
    print_warning "Computer type not set"
  else
    print_info "Computer type: ${_DOTFILES_COMPTYPE}"
  fi
}

is_home_computer() {
  load_computer_type
  if [ "${_DOTFILES_COMPTYPE}" == "${_COMPTYPE_HOME}" ]; then
    return 0
  else 
    return 1
  fi
}

is_work_computer() {
  load_computer_type
  if [ "${_DOTFILES_COMPTYPE}" == "${_COMPTYPE_WORK}" ]; then
    return 0
  else 
    return 1
  fi
}

################################################################################
# Platform checks
################################################################################

is_mac() {
  if [ $(uname -s) == "Darwin" ]; then return 0; else return 1; fi
}

is_big_sur() {
  if [ $(sw_vers -productVersion) == "10.16" ]; then return 0; else return 1; fi
}

is_win() {
  print_warning "is_win not implemented"; return 1
  #if [ grep -sq Microsoft /proc/version ]; then return 0; else return 1; fi
}

is_linux() {
  print_warning "is_linux not implemented"; return 1
}

is_pi() {
  print_warning "is_pi not implemented"; return 1
}

print_os_info() {
  local os_name="", os_vers=""

  if is_mac; then
    os_name="macOS"
  elif is_win; then
    os_name="Windows"
  elif is_pi; then
    os_name="Raspbian"
  elif is_linux; then
    if file_exists "/etc/lsb-release"; then
      os_name="Ubuntu"
    else
      os_name="$(uname -s)"
    fi
  else
    os_name="Unknown OS"
  fi

  if is_mac; then
    os_vers="$(sw_vers -productVersion)"
  elif [ "${os_name}" == "Ubuntu" ]; then
    os_vers="$(lsb_release -d | cut -f2 | cut -d' ' -f2)"
  else
    os_vers="Unknown version"
  fi

  print_info "${os_name} ${os_vers}"
}
