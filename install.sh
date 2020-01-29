#!/bin/sh
set -e

##############################################################################
# Set default paths (if not already set in ENVs)
##############################################################################
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
OHMYZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
DOTFILES_TOOLS_DIR="${DOTFILES_DIR}/_dotfiles_tools"

main() {
  check_if_first_run

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
  pushd "$DOTFILES_DIR" >/dev/null



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

    if is_mac; then
      XCUSERDATA="${HOME}/Library/Developer/Xcode/UserData"
      mkdir -p "${XCUSERDATA}"
      link_file ${DOTFILES_DIR}/Xcode/xcdebugger "${XCUSERDATA}/xcdebugger"
      link_file ${DOTFILES_DIR}/Xcode/FontAndColorThemes "${XCUSERDATA}/FontAndColorThemes"
      link_file ${DOTFILES_DIR}/Xcode/KeyBindings "${XCUSERDATA}/KeyBindings"

      ITERM_PROFILES="${HOME}/Library/Application Support/iTerm2/DynamicProfiles"
      mkdir -p "${ITERM_PROFILES}"
      link_file "${DOTFILES_DIR}/iTerm/profiles.json" "${ITERM_PROFILES}/profiles.json"
    fi

    print_if_skipped $symlink_skip_count "dotfiles symlinks"

    # Load environment variables for the rest of the script
    source "${DOTFILES_DIR}/zsh/20-exports.zsh"
  }
  _link_dotfiles



  ##############################################################################
  #                    ___           __                                         
  #                   / _ \___ _____/ /_____ ____ ____ ___                      
  #                  / ___/ _ `/ __/  '_/ _ `/ _ `/ -_|_-<                      
  #                 /_/   \_,_/\__/_/\_\\_,_/\_, /\__/___/                      
  #                                         /___/                               
  ##############################################################################
  if is_mac; then
    title "Installing Homebrew packages..."
    if command_exists "brew"; then
      # Disable auto-update to prevent it triggering between packages
      export HOMEBREW_NO_AUTO_UPDATE=1
      # Load taps
      brew tap homebrew/cask-versions

      # General CLI tools
      install_brew bat
      install_brew gnu-sed
      install_brew htop
      install_brew iperf3
      install_brew lsd
      install_brew mas
      install_brew neofetch
      install_brew nmap
      install_brew spark
      install_brew the_silver_searcher
      install_brew tmux
      install_brew trash
      install_brew tree
      install_brew wakeonlan
      install_brew watch
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
      install_brew ios-deploy
      install_brew ios-sim
      install_brew libimobiledevice
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
      install_cask 1password6
      install_cask alfred
      install_cask android-studio
      install_cask atom
      #install_cask arduino # Requires adoptopenjdk
      install_cask beyond-compare
      install_cask cocoarestclient
      print_warning "TODO: Skipping install of Discord"
      #install_cask discord # Seems to cause problems with the install script :()
      install_cask docker
      install_cask firefox
      install_cask flotato
      install_cask geekbench
      install_cask geotag
      install_cask google-chrome
      install_cask handbrake
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
      print_warning "TODO: Skipping install of VirtualBox"
      #install_cask virtualbox
      #install_cask virtualbox-extension-pack
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
      qlmanage -r
    else
      print_warning "Skipping Brew & Cask packages as homebrew isn't installed"
    fi

    if command_exists mas; then
      title "Installing Mac App Store apps..."
      if ! mas account > /dev/null; then
        if ask "Sign in to Mac App Store to install apps?"; then
          open "/Applications/App Store.app"
          print_waiting
        fi
      fi
      if mas account > /dev/null; then
        install_mas_app 824171161   "Affinity Designer"
        install_mas_app 1037126344  "Apple Configurator"
        install_mas_app 411643860   "DaisyDisk"
        install_mas_app 435003921   "Fantastical"
        install_mas_app 449830122   "HyperDock"
        install_mas_app 928871589   "Noizio"
        install_mas_app 407963104   "Pixelmator"
        install_mas_app 568494494   "Pocket"
        install_mas_app 880001334   "Reeder"
        install_mas_app 557168941   "Tweetbot"
        install_mas_app 1320666476  "Wipr"
      else
        print_warning "Skipping App Store apps as mas isn't signed in"
      fi
    else
      print_warning "Skipping App Store apps as mas isn't installed"
    fi
  elif is_linux; then
    print_warning "TODO: Install apt packages"
  fi


  title "Installing NPM packages..."
  if command_exists "npm"; then
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
  else
    print_warning "Skipping NPM packages as npm isn't installed"
  fi


  title "Installing Ruby Gem packages..."
  if command_exists "gem"; then
    install_gem cocoapods
    install_gem xcodeproj
    install_gem xcpretty
  else
    print_warning "Skipping Ruby Gems as gem isn't installed"
  fi


  title "Finishing touches..."
  ##############################################################################
  # Set zsh as shell
  ##############################################################################
  if [[ $(echo $SHELL) =~ "zsh" ]]; then
    print_success "ZSH already set as shell"
  elif [[ $(cat /etc/shells | grep -e "/zshf$") ]]; then
    print_info "Setting shell to ZSH..."
    chsh -s $(grep /zsh$ /etc/shells | tail -1)
    print_success "ZSH will be the default shell on the next session."
  else
    print_warning "ZSH is not installed, not changing shell"
  fi


  ##############################################################################
  # Font handling
  ##############################################################################
  for FONT_PATH in ${DOTFILES_DIR}/fonts/*; do
    install_font "${FONT_PATH}"
  done


  ##############################################################################
  # macOS preferences
  ##############################################################################
  if is_mac; then
    if is_first_run; then
      if ask "Set macOS default preferences?"; then
        source "${DOTFILES_TOOLS_DIR}/macos/setup_defaults.sh"
      fi
      cp "${DOTFILES_TOOLS_DIR}/macos/Post-Setup TODO.txt" "${HOME}/Desktop"
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
  _print_in_green "[✓] $1\n"
}

print_error() {
  _print_in_red "[𝘅] $1\n"
}

print_warning() {
  _print_in_yellow "/!\ $1\n"
}

print_info() {
  printf "[i] $1\n"
}

print_deleted() {
  _print_in_red "[𝘅] $1\n"
}

print_waiting() {
  printf "[ ] Press enter to continue...\n"
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
    echo $n " ❓  $1 [y/n] $c"
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
  if [ -e "${1}" ]; then return 0; else return 1; fi
}

dir_exists() {
  if [ -d "${1}" ]; then return 0; else return 1; fi;
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
install_npm() {
  if dir_exists "$(npm config get prefix)/lib/node_modules/$1"; then
    print_success "$1 already installed"
  elif [[ $(npm list -g --depth=0 --parseable | grep -e "/${1}$") ]]; then
    print_success "$1 already installed"
  else
    print_info "Installing $1..."
    if [[ $(npm install -g --no-progress $1) ]]; then
      print_success "Installed $1"
    else
      print_error "Error installing $1"
    fi
  fi
}

install_brew() {
  # Try the quick check for whether the brew's folder exists.
  # If that fails, try the slower but more reliable "brew ls --versions"
  # (for things like python3).
  if dir_exists "$(brew --cellar)/$1"; then
    print_success "$1 already installed"
  elif brew ls --versions $1 > /dev/null; then
    print_success "$1 already installed"
  else
    print_info "Installing $1..."
    if [[ $(brew install $1) ]]; then
      print_success "Installed $1"
    else
      print_error "Error installing $1"
    fi
  fi
}

install_cask() {
  # Use the same logic as above to check for cask installations
  if dir_exists "$(brew --prefix)/Caskroom/$1"; then
    print_success "$1 already installed"
  elif brew cask ls --versions $1 &> /dev/null; then
    print_success "$1 already installed"
  else
    print_info "Installing $1..."
    brew cask install $1
    print_success "Installed $1"
  fi
}

install_mas_app() {
  if mas list | grep $1 &> /dev/null; then
    print_success "$2 already installed"
  else
    print_info "Installing $2..."
    mas install $1 > /dev/null
    print_success "Installed $2"
  fi
}

install_gem() {
  if gem list "$1" --installed > /dev/null; then
    print_success "$1 already installed"
  else
    gem install "$1"
    print_success "Installed $1"
  fi
}


install_font() {
  local FONTS_DIR
  local FONT_NAME=$(basename "${1}")
  if is_mac; then
    FONTS_DIR="$HOME/Library/Fonts"
  elif is_linux; then
    FONTS_DIR="$HOME/.fonts"
  elif is_win; then
    FONTS_DIR="/mnt/c/Windows/Fonts"
  else
    print_warning "Skipping font installation for unknown platform"
  fi
  if file_exists "${FONTS_DIR}/${FONT_NAME}"; then
    print_success "${FONT_NAME} already installed"
  else
    mkdir -p "${FONTS_DIR}"
    cp "${1}" "${FONTS_DIR}"
    if file_exists "${FONTS_DIR}/${FONT_NAME}"; then
      print_success "Installed font ${FONT_NAME}"
    else
      print_error "Error installing font ${FONT_NAME}"
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
