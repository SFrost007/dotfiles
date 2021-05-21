#!/bin/sh

source "${BASH_SOURCE%/*}/../inc/funcs.sh"

_main() {
  if command_exists mas; then
    title "Installing Mac App Store apps..."
    prompt_mas_signin_if_not_signed_in
    if mas account > /dev/null; then
      install_mas_app 824171161   "Affinity Designer"
      install_mas_app 824183456   "Affinity Photo"
      install_mas_app 640199958   "Apple Developer"
      install_mas_app 411643860   "DaisyDisk"
      install_mas_app 640199958   "Developer"
      install_mas_app 412448059   "Forklift"
      install_mas_app 449830122   "HyperDock"
      install_mas_app 1295203466  "Microsoft Remote Desktop"
      install_mas_app 928871589   "Noizio"
      install_mas_app 407963104   "Pixelmator"
      install_mas_app 880001334   "Reeder"
      install_mas_app 1526844137  "Search Key"
      install_mas_app 557168941   "Tweetbot"
      install_mas_app 425424353   "The Unarchiver"
      if is_home_computer; then
        #install_mas_app 435003921   "Fantastical"
        install_mas_app 568494494   "Pocket"
      fi
    else
      print_warning "Skipping App Store apps as mas isn't signed in"
    fi
  else
    print_warning "Skipping App Store apps as mas isn't installed"
  fi
}

prompt_mas_signin_if_not_signed_in() {
  if ! mas account > /dev/null; then
    if ask "Sign in to Mac App Store to install apps?"; then
      if is_big_sur; then
        open "/System/Applications/App Store.app"
      else
        open "/Applications/App Store.app"
      fi
      print_waiting
    fi
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

_main
