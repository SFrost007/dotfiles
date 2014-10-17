#!/bin/bash
# Installs homebrew and desired brews

# TODO: Check prerequisite that Xcode is installed with developer tools
#  Or return early

if test ! $(which brew); then
	echo 'Installing Homebrew...'
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
	echo 'Homebrew already installed'
fi

brew doctor
brew tap caskroom/cask
brew tap caskroom/fonts
brew tap caskroom/versions
brew install brew-cask

# TODO: Make sure this path works
brew bundle brewfile
