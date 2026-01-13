#!/bin/sh

source "${BASH_SOURCE%/*}/../inc/funcs.sh"

title "Installing Homebrew packages..."


BREWS=(
  bat                   # Colorised 'cat' replacement
  carthage              # iOS Package manager
  cloc                  # Count lines of code
  cocoapods             # iOS Package manager
  exiftool              # Photo metadata
  ffmpeg                # Video processing
  figlet                # Ascii art
  git                   # Up to date SCM (+lfs +extras)
  #grep                  # GNU-compatible 'grep'
  gnu-sed               # Search/replace
  #howdoi                # Primitive AI assistant
  #htop                  # Task manager
  #hub                   # Github helper
  #httpie                # Web request helper
  ideviceinstaller      # iOS IPA installer
  imagemagick           # Image manipulation tool
  ios-deploy            # iOS IPA installer
  iperf3                # Network performance monitor
  jq                    # JSON processor
  #libadwaita            # Gnome UI library?
  lsd                   # Colorised/iconised 'ls' replacement
  mas                   # Mac App Store
  #mvfst                # "QUIC transport protocol implementation"?
  neofetch              # System info
  nmap                  # Network tool
  node                  # Updated Javascript runtime
  pngcrush              # PNG Compressor
  python3               # Updated Python runtime
  #ranger                # CLI file browser
  spark                 # CLI graphs (used by scripts)
  swiftlint             # Swift linter
  #the_silver_searcher   # 'grep' replacement
  #tig                   # CLI git browser
  tldr                  # Shorter man pages
  tmux                  # Terminal Multiplexer
  #trash                 # Shortcut to move things to the trash
  tree                  # Recursive file lister
  wakeonlan             # Network tool
  watch                 # Re-run terminal commands periodically
  watchman              # Run commands on file system changes
  wget                  # Network tool
  xcbeautify            # Building swift outside Xcode
  xcode-build-server    # Building swift outside Xcode
  yq                    # YAML processor
  yt-dlp                # Youtube downloader
  zbar                  # QR code scanner
)


CASKS=(
  #alfred
  android-file-transfer             # Copy files to Android devices
  balenaetcher                      # Flash SD cards
  beyond-compare                    # Diff tool (licensed)
  chatgpt                           # AI Agent
  cocoarestclient                   # HTTP request tester
  #dash                              # Documentation browser
  db-browser-for-sqlite             # SQLite browser
  devcleaner                        # Clean up iOS dev resources
  docker                            # Container manager
  firefox                           # Web browser
  #flotato                           # Website app-ifier
  geekbench                         # Benchmark tool
  google-chrome                     # Web browser
  ios-app-signer                    # iOS IPA tool
  iterm2                            # Terminal app
  itsycal                           # Menubar calendar
  #microsoft-teams                   # Video call tool (just use the site)
  monitorcontrol                    # Control brightness/volume natively
  sf-symbols                        # iOS dev tool
  #skitch                            # Image markup tool
  slack                             # Chat
  sourcetree                        # Git browser
  sublime-text                      # Text editor
  trae                              # AI agent IDE
  visual-studio-code                # Text editor
  vlc                               # Media player
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
    apktool                         # Reverse-engineer APKs
    bchunk                          # Convert bin/cue to iso/cdr
    certbot                         # LetsEncrypt helper
    chargepoint/xcparse/xcparse     # Extract screenshots from XCTest
    #cmake                           # Build tool
    #folderify                       # Add icons to folders, built into Tahoe
    freeimage                       # Graphics library
    #gobject-introspection           # No idea
    #google-cloud-sdk                # SDK for managing Google Cloud instances
    #guile                           # No idea
    httrack                         # Website mirror-er
    #icu4c                           # No idea
    jp2a                            # JPEG to Ascii converter
    llvm                            # Compiler
    lynx                            # Terminal web browser
    #mbedtls                         # No idea
    nethack                         # Terminal game
    #nghttp2                         # C HTTP library
    p7zip                           # 7zip library
    rclone                          # Network tool
    rogue                           # Terminal game
    rom-tools                       # ROM management
    #six                             # Deprecated python library
    #smartmontools                   # HDD SMART monitor
    #unison                          # File management tool
    xdelta                          # ROM patch tool
    #youtube-dl                      # Replaced by yt-dlp
  )

  CASKS+=(
    #android-studio                  # Android IDE
    homebrew/cask-versions/1password6
    discord                         # Chat
    geotag                          # Photo EXIF editor  
    handbrake                       # Video processor
    #iina                            # Media player
    #maestral                        # Dropbox replacement
    #mongodb-compass                 # Database browser
    multipatch                      # ROM patching tool
    openemu                         # Emulator frontend
    #openmtp                         # Android file browser
    #qlstephen                       # Quicklook tool
    #skype                           # Video call tool (deprecated)
    #spotify                         # Streaming music
    steam                           # Games store
    syncthing                       # File sync utility
    #syntax-highlight                # Quicklook code viewer (deprecated?)
    transmission                    # "File utility"
    utm                             # Virtual machine manager
    vnc-viewer                      # Remote desktop client
    #xcodes                          # Xcode downloader
    #zoom                           # Video calls
  )
fi

if is_work_computer; then
  print_info "Adding work computer brews/casks"
  BREWS+=(
    fontforge                       # Font manipulation
  )

  CASKS+=(
    android-studio                  # Android IDE
    claude                          # AI Agent
    claude-code                     # AI Agent
    codex                           # AI Agent
    fontforge                       # Font manipulation
    ghostty                         # Terminal app
    #insomnia                       # REST client
    postman                         # REST client/documentation
    proxyman                        # iOS request interceptor
    sequel-ace                      # Database browser
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
