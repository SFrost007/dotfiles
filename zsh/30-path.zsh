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
# Ruby gems
addPathDir $GEM_HOME/bin
# My scripts
addPathDir $DOTFILES_DIR/bin
