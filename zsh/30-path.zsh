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
# GNU utilities
addPathDir "/usr/local/opt/coreutils/libexec/gnubin"
# SDKs
addPathDir $HOME/Code/SDKs/flutter/bin
# My scripts
addPathDir $DOTFILES_DIR/bin
