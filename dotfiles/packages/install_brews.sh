#!/bin/sh

source "${BASH_SOURCE%/*}/../inc/funcs.sh"

title "Installing Homebrew packages..."


BREWS=(
  # General CLI tools
  bat
  figlet
  gnu-sed
  htop
  iperf3
  lsd
  mas
  neofetch
  nmap
  ranger
  spark
  the_silver_searcher
  tldr
  tmux
  trash
  tree
  wakeonlan
  watch
  watchman
  wget
  # CLI dev tools
  cloc
  git
  httpie
  howdoi
  hub
  jq
  node
  python3
  swiftlint
  tig
  yq
  # iOS dev tools
  carthage
  ideviceinstaller
  ios-deploy
  #ios-sim
  libimobiledevice
  usbmuxd
)


CASKS=(
  #alfred
  beyond-compare
  cocoarestclient
  dash
  db-browser-for-sqlite
  firefox
  #geekbench
  ios-app-signer
  iterm2
  sf-symbols
  skitch
  sourcetree
  visual-studio-code
  vlc
  zoom
)


print_warning "TODO: Skipping install of QuickLook plugins"
#CASKS+=(
#  qlcolorcode 
#  qlimagesize 
#  qlmarkdown 
#  qlprettypatch 
#  qlstephen
#  quicklook-csv
#  quicklook-json
#  suspicious-package
#)


if is_home_computer; then
  print_info "Adding home computer brews/casks"
  BREWS+=(
    # Terminal fun stuff
    lynx
    nethack
    rogue
    # Image/video tools
    #exiftool # Requires adoptopenjdk
    ffmpeg
    google-cloud-sdk
    imagemagick
    jp2a
    youtube-dl
  )

  CASKS+=(
    homebrew/cask-versions/1password6
    #android-studio
    balenaetcher
    discord
    geotag
    #handbrake
    mongodb-compass
    openemu
    skype
    steam
    transmission
    vnc-viewer
  )
fi

if is_work_computer; then
  print_info "Adding work computer brews/casks"
  CASKS+=(
    docker
    #flotato
    google-chrome
    insomnia
    slack
  )
fi



_main() {
  # Disable auto-update to prevent it triggering between packages
  export HOMEBREW_NO_AUTO_UPDATE=1

  if command_exists "brew"; then
    for pkg in ${BREWS[@]}; do
      install_brew $pkg
    done
    for pkg in ${CASKS[@]}; do
      install_cask $pkg
    done
    install_sublime
  else
    print_warning "Skipping Brew & Cask packages as homebrew isn't installed"
  fi

  # Restart QuickLook
  # qlmanage -r
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
    if is_big_sur; then
      # Don't consume the installation log so we can check what's happening
      brew install $1
    else
      if [[ $(brew install $1) ]]; then
        print_success "Installed $1"
      else
        print_error "Error installing $1"
      fi
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
    brew install --cask $1
    print_success "Installed $1"
  fi
}

# Sublime text switched to new licensing with v4, so install the last v3 build on HomeBrew (3.211, 10/4/2021).
# Technically the last working build is 4105, from https://download.sublimetext.com/sublime_text_build_4105_mac.zip
# or https://download.sublimetext.com/sublime_text_build_4105_x64.zip (Windows).
# `sublime-text.rb` in this directory is saved from https://raw.githubusercontent.com/Homebrew/homebrew-cask/57fc71c2e4e9cd78071eb44faced090567be8bfe/Casks/sublime-text.rb
install_sublime() {
  brew install -s sublime-text.rb
}

_main
