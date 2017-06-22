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
# Work paths
addPathDir $HOME/Code/WorkProjects/builds
addPathDir $HOME/Code/WorkProjects/tools
addPathDir /Applications/CMake_3.4.3.app/Contents/bin
# My scripts
addPathDir $DOTFILES/bin
