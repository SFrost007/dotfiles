#!/bin/zsh

###########################################################
# Setup Path                                              #
###########################################################
alias pathlist='echo -e "${PATH//:/\n}"'
function addPathDir() {
  if [ -d $1 ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH=$1:$PATH
  fi
}
# SDKs
addPathDir $HOME/Code/SDKs/flutter/bin
addPathDir $HOME/Code/SDKs/google-cloud-sdk/bin
# Ruby gems
addPathDir $GEM_HOME/bin
# My scripts
addPathDir $DOTFILES_DIR/bin
# Git helper to avoid external dependency breaking `git diff`
addPathDir $DOTFILES_DIR/git/diff-so-fancy
# Machine-local (not git controlled) binaries
addPathDir $HOME/.bin

# Special handling for homebrew on M1 macs
if [ -e /opt/homebrew/bin/brew ]; then
  eval $(/opt/homebrew/bin/brew shellenv)
fi
