#!/usr/bin/env bash
set -e

main() {
  ##############################################################################
  # Set default path if not already set externally
  ##############################################################################
  DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
  OHMYZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
  SETUPTOOLS_DIR="${DOTFILES_DIR}/_install"

  printf "\033[1m\033[41m\033[97m
                            __      __  _____ __                                
                       ____/ /___  / /_/ __(_) /__  _____                       
                      / __  / __ \/ __/ /_/ / / _ \/ ___/                       
                     / /_/ / /_/ / /_/ __/ / /  __(__  )                        
                     \__,_/\____/\__/_/ /_/_/\___/____/                         
                     \033[0m
  "

  title "Pre-checks..."

  ##############################################################################
  # Download and extract the repo contents if we're running the script remotely
  ##############################################################################
  if ! dir_exists "$DOTFILES_DIR"; then
    print_info "Script appears to be running remotely"
    if command_exists "git"; then
      exit_with_message "Git clone of dotfiles not yet implemented"
      # TODO: Set REMOTE_URL to https or ssh based on presence of SSH key
      #git clone "${REMOTE_URL}" "${DOTFILES_DIR}"
    else
      print_info "Git does not exist, downloading dotfiles.zip from Github..."
      curl -fsSL https://github.com/SFrost007/dotfiles/archive/master.zip > dotfiles.zip
      print_info "Extracting..."
      unzip -q dotfiles.zip && mv dotfiles-master "${DOTFILES_DIR}" && rm dotfiles.zip
      print_warning "TODO: Set git origin for dotfiles directory once git exists"
    fi
  fi


  ##############################################################################
  # Print some pre-run information
  ##############################################################################

  print_os_info
  if is_online; then
    print_success "Internet connection is online"
  else
    exit_with_message "Internet connection is offline"
  fi

  _PREVIOUSLY_RUN_FLAG="${SETUPTOOLS_DIR}/.installed"
  if file_exists "${_PREVIOUSLY_RUN_FLAG}"; then
    print_success "Previously installed dotfiles, skipping confirmation"
  else
    print_info "╭───────────────────────────────────────────────────────────────╮"
    print_info "│ It looks like this is the first time you're using dotfiles.   │"
    print_info "│                                                               │"
    print_info "│ This script runs mostly without prompts, and automatically    │"
    print_info "│ installs/configures software as defined in the config files in│"
    print_info "│ the repository. You should be sure this is what you want!     │"
    print_info "╰───────────────────────────────────────────────────────────────╯"
    if ask "Are you sure you want to continue?"; then
      touch "${_PREVIOUSLY_RUN_FLAG}"
      FIRST_RUN=1
    else
      print_info "OK, bye!\n" && exit 0
    fi
  fi



  title "Core tools..."
  ##############################################################################
  # Homebrew
  ##############################################################################
  if is_mac; then
    if command_exists "brew"; then
      print_success "Homebrew already installed"
    else
      print_info "Installing Homebrew..."
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
  else
    print_info "Not macOS, skipping Homebrew"
  fi



  ##############################################################################
  # oh-my-zsh
  ##############################################################################
  if dir_exists "${OHMYZSH_DIR}"; then
    print_success "oh-my-zsh already installed"
  else
    print_info "Installing oh-my-zsh..."
    git clone -q --depth=1 https://github.com/robbyrussell/oh-my-zsh.git "${OHMYZSH_DIR}"
  fi



  ##############################################################################
  # SSH key
  ##############################################################################
  if file_exists "${HOME}/.ssh/id_rsa"; then
    print_success "SSH key exists"
    print_warning "TODO: Add helpers to create SSH key if missing"
  else
    print_warning "No SSH key; you may wish to configure one"
  fi



  ##############################################################################
  # Link dotfiles
  ##############################################################################
  symlink_skip_count=0
  _link_dotfiles() {
    title "Linking dotfiles..."
    local TARGET_DIR=$HOME
    local overwrite_all=false backup_all=false skip_all=false

    link_file ${DOTFILES_DIR}/git/.gitconfig ${TARGET_DIR}/.gitconfig
    link_file ${DOTFILES_DIR}/rtv/rtv.cfg ${TARGET_DIR}/.config/rtv/rtv.cfg
    link_file ${DOTFILES_DIR}/rtv/.mailcap ${TARGET_DIR}/.mailcap
    link_file ${DOTFILES_DIR}/tmux/oh-my-tmux/.tmux.conf ${TARGET_DIR}/.tmux.conf
    link_file ${DOTFILES_DIR}/tmux/.tmux.conf.local ${TARGET_DIR}/.tmux.conf.local
    link_file ${DOTFILES_DIR}/twterm ${TARGET_DIR}/.twterm
    link_file ${DOTFILES_DIR}/vim/.vimrc ${TARGET_DIR}/.vimrc
    link_file ${DOTFILES_DIR}/vim/.vim ${TARGET_DIR}/.vim
    link_file ${DOTFILES_DIR}/zsh/.zshrc ${TARGET_DIR}/.zshrc
    link_file ${DOTFILES_DIR}/zsh/.zshenv ${TARGET_DIR}/.zshenv
    link_file ${DOTFILES_DIR}/zsh/.hushlogin ${TARGET_DIR}/.hushlogin

    mkdir -p ${TARGET_DIR}/.ssh
    link_file ${DOTFILES_DIR}/ssh/config ${TARGET_DIR}/.ssh/config
    link_file ${DOTFILES_DIR}/ssh/config.d ${TARGET_DIR}/.ssh/config.d

    if [[ $symlink_skip_count -gt 0 ]]; then
      print_info "Skipped ${symlink_skip_count} existing symlinks"
    fi
  }
  _link_dotfiles



  ##############################################################################
  # Install packages
  ##############################################################################
  title "Installing packages..."
  if is_mac; then
    print_warning "TODO: Install brew packages"
    print_warning "TODO: Install cask packages"
    print_warning "TODO: Install AppStore apps"
  elif is_linux; then
    print_warning "TODO: Install apt packages"
  fi
  print_warning "TODO: Install npm packages"
  print_warning "TODO: Install gem packages"



  title "Finishing touches..."
  ##############################################################################
  # Set zsh as shell
  ##############################################################################
  if [[ $(echo $SHELL) =~ "zsh" ]]; then
    print_success "ZSH already set as shell"
  else
    print_info "Setting shell to ZSH..."
    chsh -s $(grep /zsh$ /etc/shells | tail -1)
    print_success "ZSH will be the default shell on the next session."
  fi


  print_warning "TODO: Install fonts via brew tap caskroom/fonts (or fallbacks)"
  #cd ~/Library/Fonts && { curl -O 'https://github.com/Falkor/dotfiles/blob/master/fonts/SourceCodePro+Powerline+Awesome+Regular.ttf?raw=true' ; cd -; }


  ##############################################################################
  # macOS preferences
  ##############################################################################
  if is_mac; then
    if is_first_run; then
      if ask "Set macOS default preferences?"; then
        source "${SETUPTOOLS_DIR}/macos_setup.sh"
      fi
    else
      print_info "Not first run, skipping macOS defaults script"
    fi
  fi


  ##############################################################################
  # Exit message (figlet -f smslant)
  ##############################################################################
  _print_in_green "
  ╭──────────────────────────────────────────────────────────────────────────╮
  │              _____             __    __                     __           │
  │             / ___/__  ___  ___/ /   / /____      ___ ____  / /           │
  │            / (_ / _ \/ _ \/ _  /   / __/ _ \    / _ '/ _ \/_/            │
  │            \___/\___/\___/\_,_/    \__/\___/    \_, /\___(_)             │
  │                                                /___/                     │
  ╰──────────────────────────────────────────────────────────────────────────╯
  \n"
}




################################################################################
#          __ __    __               ____              __  _             
#         / // /__ / /__  ___ ____  / __/_ _____  ____/ /_(_)__  ___  ___
#        / _  / -_) / _ \/ -_) __/ / _// // / _ \/ __/ __/ / _ \/ _ \(_-<
#       /_//_/\__/_/ .__/\__/_/   /_/  \_,_/_//_/\__/\__/_/\___/_//_/___/
#                 /_/                                                    
################################################################################


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

title_count=1
title() {
  local fmt="$1"; shift
  printf "
✦  ${bold}$((title_count++)). $fmt${normal}
└──────────────────────────────────────────────────────────────────────────────○
" "$@"
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

ask() {
  local reply
  while true; do
    echo -n " ❓ $1 [y/n] "
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
# Pre-checks for various conditions
################################################################################

is_online() {
  if nc -zw1 google.com 443 &>/dev/null; then return 0; else return 1; fi
}

is_first_run() {
  if [ -z "FIRST_RUN" ]; then return 0; else return 1; fi
}

file_exists() {
  if [ -e $1 ]; then return 0; else return 1; fi
}

dir_exists() {
  if [ -d $1 ]; then return 0; else return 1; fi;
}

command_exists() {
  type $1 >/dev/null 2>&1 || return 1; return 0;
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
#                  ___                          _      __ 
#                 / _ \__ _____    ___ ________(_)__  / /_
#                / , _/ // / _ \  (_-</ __/ __/ / _ \/ __/
#               /_/|_|\_,_/_//_/ /___/\__/_/ /_/ .__/\__/ 
#                                             /_/         
################################################################################
main
