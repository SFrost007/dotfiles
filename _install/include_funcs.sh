#!/usr/bin/env bash
# Lots of things here are pinched from Formation's "twirl" script
# https://github.com/minamarkham/formation/blob/master/twirl


################################################################################
# Colo(u)r handling
################################################################################

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

################################################################################
# Print handlers
################################################################################

title_count=1
title() {
    local fmt="$1"; shift
    printf "\n✦  ${bold}$((title_count++)). $fmt${normal}\n"
    printf "└──────────────────────────────────────────────────────────────────────○\n" "$@"
}

print_success() {
  _print_in_green " ✅  $1\n"
}

print_error() {
  _print_in_red " ⛔️  $1\n"
}

print_warning() {
  _print_in_yellow " ⚠️   $1\n"
}

print_info() {
  _print_in_white " ℹ️   $1\n"
}

print_deleted() {
  _print_in_red " 🗑   $1\n"
}

exit_with_message() {
  print_error "$1\n" && exit 1
}

################################################################################
# Prompts
################################################################################

ask_for_sudo() { # https://gist.github.com/cowboy/3118588
    sudo -v &> /dev/null
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    print_success "Password cached"
}

ask() { # https://djm.me/ask
    local prompt default reply

    while true; do
        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -n " ❓ $1 [$prompt] "
        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read reply </dev/tty

        # Default?
        if [ -z "$reply" ]; then
            reply=$default
        fi

        # Check if the reply is valid
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
    done
}


################################################################################
# Platform checks
################################################################################

is_mac() {
  if [ $(uname -s) == "Darwin" ]; then return 0; else return 1; fi
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


################################################################################
# Pre-checks for various conditions
################################################################################

is_online() {
  if nc -zw1 google.com 443 &>/dev/null; then return 0; else return 1; fi
}

check_file_exists() {
  if [ -e $1 ]; then return 0; else return 1; fi
}

check_dir_exists() {
  if [ -d $1 ]; then return 0; else return 1; fi
}

check_command_exists() {
  type $1 >/dev/null 2>&1 || return 1; return 0;
}


################################################################################
# Symlink creator with prompts
################################################################################

link_file() {
  local src=$1 dst=$2
  local overwrite= backup= skip= action=

  # Protect against doing something unintended and destructive, like removing a
  # directory when trying to link a file and choosing "Overwrite"
  if [[ -d "$dst" && ! -d "$src" ]]; then
    echo "Linking source file to destination directory not supported"; return 1
  fi

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]; then
    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]; then
      local currentSrc=`readlink "$dst"`
      if [ "$currentSrc" == "$src" ]; then
        symlink_skip_count=$((symlink_skip_count+1))
        skip=true;
      else
        _print_in_white " ❓  File already exists: $(basename "$dst").\n     [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all? "
        read -n 1 action
        echo ""

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac
      fi
    fi
  fi

  overwrite=${overwrite:-$overwrite_all}
  backup=${backup:-$backup_all}
  skip=${skip:-$skip_all}

  if [ "$overwrite" == "true" ]; then
    rm -rf "$dst"
    print_deleted "Removed $dst"
  fi

  if [ "$backup" == "true" ]; then
    mv "$dst" "${dst}.bak"
    print_success "Moved $dst to ${dst}.bak"
  fi

  #if [ "$skip" == "true" ]; then
  #  print_info "Skipped $dst"
  #fi

  # Actually create the symlink if required
  if [ "$skip" != "true" ]; then
    ln -s "$src" "$dst"
    print_success "Created $dst"
  fi
}


################################################################################
# OS Info
################################################################################
print_os_info() {
  local os_name="", os_vers=""

  if is_mac; then
    os_name="macOS"
  elif is_win; then
    os_name="Windows"
  elif is_pi; then
    os_name="Raspbian"
  elif is_linux; then
    if check_file_exists "/etc/lsb-release"; then
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


################################################################################
# Self-testing function, run if this script is executed rather than sourced
################################################################################

_test_funcs() {
  # Colour printing functions
  title "Colo(u)rs"
  _print_in_red "Red\n"
  _print_in_green "Green\n"
  _print_in_yellow "Yellow\n"
  _print_in_blue "Blue\n"
  _print_in_purple "Purple\n"
  _print_in_cyan "Cyan\n"
  _print_in_white "White\n"

  title "Print handlers"
  print_success "Success"
  print_error "Error"
  print_warning "Warning"
  print_info "Info"

  title "Platform checks"
  if is_mac; then
    echo " 🍎 Is macOS"
  else
    echo " ❌ Not macOS"
  fi

  if is_win; then
    echo " 🖼 Is Windows"
  else
    echo " ❌ Not Windows"
  fi

  if is_linux; then
    echo " 🐧 Is Linux"
  else
    echo " ❌ Not Linux"
  fi

  if is_pi; then
    echo " 🍓 Is RaspberryPi"
  else
    echo " ❌ Not RaspberryPi"
  fi
}
(return 0 2>/dev/null) || _test_funcs
