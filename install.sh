#!/bin/sh
set -e

main() {
  check_if_first_run

  ##############################################################################
  # Set default paths (if not already set in ENVs)
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
  print_os_info

  if is_online; then
    print_success "Internet connection is online"
  else
    exit_with_message "Internet connection is offline"
  fi

  ##############################################################################
  # Install macOS Command Line Tools (inc. git) if not already done
  ##############################################################################
  if is_mac; then
    if file_exists "/Library/Developer/CommandLineTools/usr/bin/git"; then
      print_success "Command Line Tools installed"
    else
      print_info "Requesting install of Xcode Command Line Tools"
      xcode-select --install
      print_waiting
    fi
  fi

  ##############################################################################
  # Download and extract the repo contents if we're running the script remotely
  ##############################################################################
  if dir_exists "$DOTFILES_DIR"; then
    print_success "Dotfiles dir exists"
  else
    print_info "╭───────────────────────────────────────────────────────────────╮"
    print_info "│ It looks like this is the first time you're using dotfiles.   │"
    print_info "│                                                               │"
    print_info "│ This script runs mostly without prompts, and automatically    │"
    print_info "│ installs/configures software as defined in the config files in│"
    print_info "│ the repository. You should be sure this is what you want!     │"
    print_info "╰───────────────────────────────────────────────────────────────╯"
    if ! ask "Are you sure you want to continue?"; then
      print_info "OK, bye!\n" && exit 0
    fi

    if command_exists "git"; then
      print_info "Using git to clone into ${DOTFILES_DIR}"

      if ssh_key_exists; then
        print_success "Existing SSH key found"
      else
        if ask "No SSH key found. Create one?"; then
          create_ssh_key
        fi
      fi

      if ssh_key_exists; then
        if ask "Copy SSH key to the clipboard (to add to Github)?"; then
          copy_ssh_key_and_open_github
          CLONE_WITH_SSH=1
        fi
      fi

      if [[ $CLONE_WITH_SSH -eq 1 ]]; then
        REPO_URL="git@github.com:SFrost007/dotfiles.git"
      else
        print_warning "Cloning dotfiles via HTTPS, updates cannot be committed back."
        REPO_URL="https://github.com/SFrost007/dotfiles.git"
      fi
      git clone --recursive --quiet "${REPO_URL}" "${DOTFILES_DIR}"
    else
      print_info "Git does not exist, downloading dotfiles.zip from Github..."
      print_warning "Cloning via SSH is recommended; this method excludes submodules."
      print_waiting
      curl -fsSL https://github.com/SFrost007/dotfiles/archive/master.zip > dotfiles.zip
      print_info "Extracting..."
      unzip -q dotfiles.zip && mv dotfiles-master "${DOTFILES_DIR}" && rm dotfiles.zip
      print_warning "TODO: Set git origin for dotfiles directory once git exists"
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
      print_info "Installing Homebrew..." && sleep 2
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      printf "\n\n"
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
    print_info "Installing oh-my-zsh..." && sleep 2
    git clone -q --depth=1 https://github.com/robbyrussell/oh-my-zsh.git "${OHMYZSH_DIR}"
  fi



  ##############################################################################
  # Submodules update
  ##############################################################################
  if command_exists "git"; then
    # TODO: Could do something more "intelligent" here, but this works..
    print_info "Updating submodules..."
    git submodule update --init
  else
    print_warning "Skipping submodule update as 'git' does not exist"
  fi



  ##############################################################################
  # Link dotfiles
  ##############################################################################
  _link_dotfiles() {
    title "Linking dotfiles..."
    local TARGET_DIR=$HOME
    local overwrite_all=false backup_all=false skip_all=false

    link_file ${DOTFILES_DIR}/git/.gitconfig ${TARGET_DIR}/.gitconfig
    link_file ${DOTFILES_DIR}/rtv/.mailcap ${TARGET_DIR}/.mailcap
    link_file ${DOTFILES_DIR}/tmux/oh-my-tmux/.tmux.conf ${TARGET_DIR}/.tmux.conf
    link_file ${DOTFILES_DIR}/tmux/.tmux.conf.local ${TARGET_DIR}/.tmux.conf.local
    link_file ${DOTFILES_DIR}/twterm ${TARGET_DIR}/.twterm
    link_file ${DOTFILES_DIR}/vim/.vimrc ${TARGET_DIR}/.vimrc
    link_file ${DOTFILES_DIR}/vim/.vim ${TARGET_DIR}/.vim
    link_file ${DOTFILES_DIR}/zsh/.zshrc ${TARGET_DIR}/.zshrc
    link_file ${DOTFILES_DIR}/zsh/.zshenv ${TARGET_DIR}/.zshenv
    link_file ${DOTFILES_DIR}/zsh/.hushlogin ${TARGET_DIR}/.hushlogin

    mkdir -p ${TARGET_DIR}/.config/rtv
    link_file ${DOTFILES_DIR}/rtv/rtv.cfg ${TARGET_DIR}/.config/rtv/rtv.cfg

    mkdir -p ${TARGET_DIR}/.ssh
    link_file ${DOTFILES_DIR}/ssh/config ${TARGET_DIR}/.ssh/config
    link_file ${DOTFILES_DIR}/ssh/config.d ${TARGET_DIR}/.ssh/config.d

    print_if_skipped $symlink_skip_count "dotfiles symlinks"
  }
  _link_dotfiles



  ##############################################################################
  #         ___                                    __                           
  #        / _ )_______ _    __     ___  ___ _____/ /_____ ____ ____ ___        
  #       / _  / __/ -_) |/|/ /    / _ \/ _ `/ __/  '_/ _ `/ _ `/ -_|_-<        
  #      /____/_/  \__/|__,__/    / .__/\_,_/\__/_/\_\\_,_/\_, /\__/___/        
  #                              /_/                      /___/                 
  ##############################################################################
  if is_mac; then
    if command_exists "brew"; then
      title "Installing Homebrew packages..."
      # General CLI tools
      install_brew bat
      install_brew gnu-sed
      install_brew htop
      install_brew iperf3
      install_brew lsd
      install_brew mas
      install_brew spark
      install_brew the_silver_searcher
      install_brew tmux
      install_brew trash
      install_brew tree
      install_brew wakeonlan
      install_brew wget
      # Fun stuff
      install_brew lynx
      install_brew nethack
      install_brew rogue
      install_brew rtv
      # CLI dev tools
      install_brew cloc
      install_brew git
      install_brew howdoi
      install_brew hub
      install_brew jq
      install_brew node
      install_brew python3
      install_brew tig
      install_brew yq
      # iOS dev tools
      install_brew bitrise
      install_brew carthage
      install_brew ideviceinstaller
      install_brew ios-sim
      install_brew libimobiledevice
      install_brew sourcery
      install_brew usbmuxd
      # Web dev tools
      install_brew hugo
      install_brew now-cli
      # Image/video tools
      install_brew exiftool
      install_brew ffmpeg
      install_brew imagemagick
      install_brew jp2a
      install_brew youtube-dl

      title "Installing Homebrew Casks..."
      install_cask 1password
      install_cask alfred
      install_cask android-studio
      install_cask arduino
      install_cask beyond-compare
      install_cask cocoarestclient
      install_cask discord
      install_cask docker
      install_cask firefox
      install_cask geotag
      install_cask google-chrome
      install_cask ios-app-signer
      install_cask iterm2
      install_cask macdown
      install_cask openemu
      install_cask skitch
      install_cask skype
      install_cask slack
      install_cask sourcetree
      install_cask spotify
      install_cask steam
      install_cask sublime-text
      install_cask transmission
      install_cask virtualbox
      install_cask virtualbox-extension-pack
      install_cask visual-studio-code
      install_cask vlc
      install_cask vnc-viewer
      install_cask zoomus
      # Quicklook plugins
      install_cask qlcolorcode
      install_cask qlimagesize
      install_cask qlmarkdown
      install_cask qlprettypatch
      install_cask qlstephen
      install_cask quicklook-csv
      install_cask quicklook-json
      install_cask suspicious-package
    else
      print_warning "Skipping Brew packages as homebrew isn't installed"
    fi
  fi

  ##############################################################################
  #           __  ___           ___               ______                        
  #          /  |/  /__ _____  / _ | ___  ___    / __/ /____  _______           
  #         / /|_/ / _ `/ __/ / __ |/ _ \/ _ \  _\ \/ __/ _ \/ __/ -_)          
  #        /_/  /_/\_,_/\__/ /_/ |_/ .__/ .__/ /___/\__/\___/_/  \__/           
  #                               /_/  /_/                                      
  ##############################################################################
  if is_mac; then
    if command_exists "mas"; then
      print_warning "TODO: Install MAS packages"
    else
      print_warning "Skipping App Store apps as mas isn't installed"
    fi
  fi


  if is_linux; then
    print_warning "TODO: Install apt packages"
  fi
  print_warning "TODO: Install gem packages"


  ##############################################################################
  #           _  _____  __  ___  ___           __                               
  #          / |/ / _ \/  |/  / / _ \___ _____/ /_____ ____ ____ ___            
  #         /    / ___/ /|_/ / / ___/ _ `/ __/  '_/ _ `/ _ `/ -_|_-<            
  #        /_/|_/_/  /_/  /_/ /_/   \_,_/\__/_/\_\\_,_/\_, /\__/___/            
  #                                                   /___/                     
  ##############################################################################
  if command_exists "npm"; then
    print_info "Installing NPM packages..."
    # General tools
    install_npm diff-so-fancy
    install_npm figlet
    # Webby development
    install_npm now
    install_npm express-generator
    install_npm mongodb
    # Homebridge-related packages
    # install_npm homebridge
    # install_npm homebridge-lifx-lan
    # install_npm homebridge-superlights
    # install_npm noble

    print_if_skipped $npm_skip_count "NPM packages"
  else
    print_warning "Skipping NPM packages as npm isn't installed"
  fi


  title "Finishing touches..."
  ##############################################################################
  # Set zsh as shell
  ##############################################################################
  if [[ $(echo $SHELL) =~ "zsh" ]]; then
    print_success "ZSH already set as shell"
  else
    print_warning "TODO: Check whether ZSH exists before trying to set it"
    print_info "Setting shell to ZSH..."
    chsh -s $(grep /zsh$ /etc/shells | tail -1)
    print_success "ZSH will be the default shell on the next session."
  fi


  ##############################################################################
  # Font handling
  ##############################################################################
  if ! is_mac; then
    print_warning "TODO: Install fonts without homebrew for non-macOS platforms"
  fi


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
  printf " ℹ️   $1\n"
}

print_deleted() {
  _print_in_red " 🗑   $1\n"
}

print_waiting() {
  printf " ⏳  Press enter to continue...\n"
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
  while true; do
    echo -n " ❓  $1 [y/n] "
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
  print_warning "TODO: nc doesn't exist on Raspbian, so this fails.."
  if nc -zw1 google.com 443 &>/dev/null; then return 0; else return 1; fi
}

check_if_first_run() {
  if ! dir_exists "${DOTFILES_DIR}"; then
    FIRST_RUN=1
  fi
}

is_first_run() {
  if [ ! -z ${FIRST_RUN+x} ]; then return 0; else return 1; fi
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
# SSH key handling
################################################################################

SSH_KEY_PATH="${HOME}/.ssh/id_rsa.pub"

ssh_key_exists() {
  if file_exists "${SSH_KEY_PATH}"; then return 0; else return 1; fi
}

create_ssh_key() {
  print_info "No SSH key found. Creating one..."
  ssh-keygen -t rsa
}

offer_copy_ssh_key_for_github() {
  if ask "Copy SSH key (for pasting to Github)?"; then
    copy_ssh_key_and_open_github
  fi
}

copy_ssh_key_and_open_github() {
  if is_mac; then
    cat "${SSH_KEY_PATH}" | pbcopy
    open "https://github.com/account/ssh"
    print_success "Copied to clipboard"
    print_waiting
  else
    print_warning "TODO: Copy SSH key without pbcopy"
  fi
}


################################################################################
# Symlink creator with prompts
################################################################################
symlink_skip_count=0
link_file() {
  local src=$1 dst=$2
  local overwrite= backup= skip= action=

  # Protect against doing something unintended and destructive, like removing a
  # directory when trying to link a file and choosing "Overwrite"
  if [[ -d "$dst" && ! -d "$src" ]]; then
    print_error "Linking source file to destination directory not supported"; return 1
  fi

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]; then
    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]; then
      local currentSrc=`readlink "$dst"`
      if [ "$currentSrc" == "$src" ]; then
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

  if [ "$skip" == "true" ]; then
    symlink_skip_count=$((symlink_skip_count+1))
    #print_info "Skipped $dst"
  fi

  # Actually create the symlink if required
  if [ "$skip" != "true" ]; then
    ln -s "$src" "$dst"
    print_success "Created $dst"
  fi
}


################################################################################
# Package installations
################################################################################
npm_skip_count=0
install_npm() {
  if [[ $(npm list -g --depth=0 --parseable | grep -e "/${1}$") ]]; then
    npm_skip_count=$((npm_skip_count+1))
  else
    if [[ $(npm install -g --no-progress $1) ]]; then
      print_success "Installed $1"
    else
      print_error "Error installing $1"
    fi
  fi
}

install_brew() {
  if brew ls --versions $1 > /dev/null; then
    print_success "$1 already installed"
  else
    print_info "Installing $1..."
    if [[ $(HOMEBREW_NO_AUTO_UPDATE=1 brew install $1) ]]; then
      print_success "Installed $1"
    else
      print_error "Error installing $1"
    fi
  fi
}

install_cask() {
  if brew cask ls --versions $1 &> /dev/null; then
    print_success "$1 already installed"
  else
    print_info "Installing $1..."
    HOMEBREW_CASK_OPTS="--appdir=/Applications"
    if [[ $(HOMEBREW_NO_AUTO_UPDATE=1 brew cask install $1) ]]; then
      print_success "Installed $1"
    else
      print_error "Error installing $1"
    fi
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
