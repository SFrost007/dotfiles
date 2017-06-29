#!/bin/bash
#
# Main dotfiles install script. This can be run remotely via curl and will clone
# the repo to ~/.dotfiles and install, or can be run with a locally cloned repo
# to use that version.
# Additionally can be used a git hook to update the installation after a pull.

DOTFILES_DIR="$HOME/.dotfiles"
_CLONE_SOURCE="git@github.com:SFrost007/dotfiles.git"


# ==============================================================================
# Generic output functions
# ==============================================================================

_RED="\033[0;31m"
_GREEN="\033[00;32m"
_BLUE="\033[00;34m"
_RESET="\033[0m"

echo_blank_line() {
  echo ""
}

echo_divider() {
  for i in {0..80}; do echo -n "="; done; echo
}

echo_header() {
  echo_divider; echo "$1"; echo_divider
}

info () {
  printf "  [ ${_BLUE}..${_RESET} ] $1\n"
}

success () {
  printf "  [ ${_GREEN}OK${_RESET} ] $1\n"
}

warn () {
  printf "  [${_RED}WARN${_RESET}] $1\n"
}

fail () {
  printf "  [${_RED}FAIL${_RESET}] $1\n" && exit
}


# ==============================================================================
# Generic support functions
# ==============================================================================

PLATFORM_OSX="macOS"
PLATFORM_LINUX="Linux"
# TODO: Support Win10's Linux subsystem
# TODO: Detect Raspbian as subset of Linux?

get_platform() {
  case `uname` in
    Darwin) echo ${PLATFORM_OSX};;
    Linux) echo ${PLATFORM_LINUX};;
    *) ;;
  esac
}

check_file_exists() {
  if [ -e $1 ]; then return 0; else return 1; fi
}

check_dir_exists() {
  if [ -d $1 ]; then return 0; else return 1; fi;
}

check_command_exists() {
  type $1 >/dev/null 2>&1 || return 1; return 0;
}

array_contains() {
  local list=$1[@]; local elem=$2
  for i in "${!list}"; do
    if [ "$i" == "${elem}" ]; then return 0; fi
  done
  return 1
}


# ==============================================================================
# Dotfiles specific setup functions
# ==============================================================================

_AVAILABLE_MODULES=(${DOTFILES_DIR}/tools/setup-modules/*.sh)
_ENABLED_MODULES=()
_SELECTED_MODULES=()

load_module() {
  local MODULE_FNS=(_module_friendlyname _module_valid _module_run_after_git_pull _module_exec)
  for fn in "${MODULE_FNS[@]}"; do
    unset -f ${fn}
  done
  source $1
  for fn in "${MODULE_FNS[@]}"; do
    if ! check_command_exists $fn; then
      fail "Module $1 missing function $fn"
    fi
  done
}

print_dotfiles_info() {
  (check_dir_exists "${DOTFILES_DIR}" && \
    success "Dotfiles directory exists") || \
    warn "Dotfiles directory does not exist"
}

print_tool_info() {
  local TOOL=$1
  if check_command_exists $TOOL; then
    local VERSION_ARG=${2:---version}
    local VERSION_INFO=`$TOOL $VERSION_ARG 2>&1 | head -n 1 | \
      sed 's/[^0-9.]*\([0-9.]*\).*/\1/'`
    success "${TOOL} installed ${_GREEN}(${VERSION_INFO})${_RESET}"
  else
    warn "$TOOL is not installed"
  fi
}

print_current_info() {
  echo_header "Dotfiles installation"
  info "Platform: $(get_platform)"
  info "Shell: $SHELL"
  print_dotfiles_info
  echo_blank_line

  print_tool_info "git"
  print_tool_info "vim"
  print_tool_info "tmux" "-V"
  print_tool_info "curl"
  print_tool_info "tree"
  print_tool_info "wget"
  print_tool_info "zsh"
  print_tool_info "python"
  case `get_platform` in
    $PLATFORM_OSX) print_tool_info "brew";;
    $PLATFORM_LINUX) print_tool_info "apt-get";;
  esac
}

print_install_menu() {
  _OPTION_NUMBER=1
  for file in ${_AVAILABLE_MODULES[@]}; do
    load_module $file
    if _module_valid; then
      _ENABLED_MODULES+=($file)
      array_contains _SELECTED_MODULES $file \
        && SELECTED=" ${_GREEN}*${_RESET} " \
        || SELECTED="   "
      printf "${SELECTED}${_OPTION_NUMBER}) $(_module_friendlyname)\n"
      _OPTION_NUMBER=$((_OPTION_NUMBER+1))
    fi
  done
  if [ -z $_SELECTED_MODULES ]; then
    local NEXT_CMD="Exit"
  else
    local NEXT_CMD="Continue"
  fi
  echo "   ${_OPTION_NUMBER}) ${NEXT_CMD}"
}

run_selected_modules() {
  for file in ${_SELECTED_MODULES[@]}; do
    echo_blank_line
    load_module $file
    echo_header "Running module: `_module_friendlyname`"
    _module_exec
  done
  echo_blank_line
}

ensure_git_installed() {
  if ! check_command_exists git; then
    warn "Git is not installed. Installing.."
    case `get_platform` in
      PLATFORM_OSX) xcode-select --install;;
      PLATFORM_LINUX) sudo apt-get install git;;
    esac
    echo_blank_line
  else
    success "Git is installed."
  fi
}

ensure_ssh_key_exists() {
  local SSH_KEY_PATH="$HOME/.ssh/id_rsa.pub"
  if ! check_file_exists "$SSH_KEY_PATH"; then
    echo_blank_line
    warn "No SSH key found, but this is required to clone from Github.."
    echo_blank_line
    ssh-keygen -t rsa -b 4096
    echo_blank_line
    success "SSH Key generated. Copy the following to Github before proceeding:"
    echo_blank_line
    cat "$SSH_KEY_PATH"
    echo_blank_line
    read -n 1 -s -p "Press any key once ready.."
  else
    success "Using SSH key from $SSH_KEY_PATH."
  fi
}

add_or_remove_from_selected() {
  if array_contains _SELECTED_MODULES $1; then
    _SELECTED_MODULES=("${_SELECTED_MODULES[@]/$1}")
  else
    _SELECTED_MODULES+=($1)
  fi
}


# ==============================================================================
# Installer modes
# ==============================================================================

manual_install() {
  while :; do
    clear
    print_current_info
    echo_blank_line
    print_install_menu
    echo_blank_line

    read -p "Enter an option: " CHOICE
    if [ "$CHOICE" -eq "$_OPTION_NUMBER" ]; then
      break
    elif [[ $CHOICE =~ ^[0-9]+$ ]]; then
      local CHOICE_NUM=$(expr $CHOICE - 1)
      if [[ $CHOICE_NUM -lt $_OPTION_NUMBER ]]; then
        add_or_remove_from_selected ${_ENABLED_MODULES[$CHOICE_NUM]}
      fi
    fi
  done
  run_selected_modules
}

curl_install() {
  # While we _could_ download the tarball of the dotfiles, this will leave it
  # disconnected from the git origin. Instead, attempt to install git now.
  ensure_git_installed
  ensure_ssh_key_exists
  info "Cloning dotfiles with git.."
  git clone "${_CLONE_SOURCE}" "${DOTFILES_DIR}"
  cd $DOTFILES_DIR
  git submodule update --init
  echo "Triggering main dotfiles install script.."
  source "${DOTFILES_DIR}/tools/install.sh"
}

gitpull_update() {
  # Running from a git pull hook. We assume everything else is set up correctly
  # and just run minor (+package?) updates.
  echo "Updating dotfiles..."
  # TODO: Implement. Decide on packages or just updating linked dotfiles.
  # TODO: Update submodules
}


# ==============================================================================
# Installer modes
# ==============================================================================

if [ -z DOTFILES_PULL_HOOK ]; then
  gitpull_update
elif [ -e $DOTFILES_DIR ]; then
  manual_install
else
  curl_install
fi
