#!/bin/zsh

# Terminal utils
alias itermClear="printf '\e]50;ClearScrollback\a'"
alias rezsh='source ~/.zshrc'
alias dotfiles='code ~/.dotfiles'
alias sedrecurse='find . -type f -print | xargs sed -i ""'
alias tmuxtitle='twintitle $1'
alias twintitle='tmux rename-window $1'
alias tpanetitle='printf "\033]2;%s\033\\" "$1"'
alias termtitle='echo -ne "\033]0;$@\007";'
alias zipeachfile='for file in *; do zip ${file%.*}.zip $file; done'

# Override built-in commands
alias cp='rsync --progress -ah'
alias du='du -d1 -h'
if type lsd >/dev/null 2>&1; then
  alias ls='lsd'
fi
#if type trash >/dev/null 2>&1; then
#  alias rm='trash'
#fi

# More memorable wrapper for QR decoding library and stripping prefix
qrdecode() { zbarimg -q "$1" | sed 's/^QR-Code://' }

# Networking
alias internalip='ipconfig getifaddr en0'
alias externalip='dig +short myip.opendns.com @resolver1.opendns.com'
alias myip='echo "Internal: $(internalip)" && echo "External: $(externalip)"'
alias wakezion='wakeonlan 2c:76:8a:ab:d4:56'
alias wakedesky='wakeonlan 00:24:1d:cf:0f:d4'

# Web-dev related stuff
alias serve='python -m SimpleHTTPServer &'
alias stopserve='pkill -f SimpleHTTPServer'

# Fun stuff
alias adventure='emacs -batch -l dunnet'
alias weather='curl wttr.in'
alias yt-dl='youtube-dl -f 137+140 --no-playlist'

# Reference
cheat() { curl "cheat.sh/$1" }
pman() { man -t "$@" | open -f -a Preview; }

# OS-specific aliases
case $(uname) in
  Linux)
    alias apt-get='sudo apt-get'
    alias mount='mount | column -t'
    alias xopen='xdg-open'
    alias ports='netstat -tulanp'
    alias sudoedit='gksudo gedit'
    ;;
  Darwin)
    alias fuxcode='rm -rf ~/Library/Developer/Xcode/DerivedData'
    alias ql='qlmanage -p'
    alias caskupgrade='brew cask upgrade --greedy'
    alias addDockSpace='defaults write com.apple.dock persistent-apps -array-add "{\"tile-type\"=\"spacer-tile\";}" && killall Dock'
    ;;
esac
