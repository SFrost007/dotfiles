export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export TERM=xterm-256color

if hash subl 2>/dev/null; then
  export EDITOR="subl"
else
  export EDITOR="vim"
fi

# Ensure dotfiles are listed first in ls
export LC_COLLATE="C"
