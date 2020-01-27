#!/bin/sh

export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export GEM_HOME="${HOME}/.gem"

if hash subl 2>/dev/null; then
  export EDITOR="subl"
else
  export EDITOR="vim"
fi

# Ensure dotfiles are listed first in ls, and enable coloured output
export LC_COLLATE="C"
export CLICOLOR=true
export LSCOLORS="exfxcxdxbxegedabagacad"
