#!/bin/zsh

# General shortcuts
alias cls='clear'
alias du='du -h'
alias cp='rsync --progress -ah'
alias ccat='colorize'
alias shutdown='sudo shutdown -h now'
b64d() { echo "$1" | base64 -D }

# Useful stuff
alias myip='ifconfig | grep broadcast | awk -F " " '"'"'{print $2}'"'"
alias sedrecurse='find . -type f -print | xargs sed -i ""'
alias wakezion='wakeonlan 2c:76:8a:ab:d4:56'
alias dotfiles='subl ~/.dotfiles'
alias yt-dl='youtube-dl -f 137+140 --no-playlist'

# Web-dev related stuff
alias serve='python -m SimpleHTTPServer &'
alias stopserve='pkill -f SimpleHTTPServer'
alias prettyjson='python -m json.tool'

# Source control
alias gitcompress='git repack && git prune'

# Fun stuff
alias adventure='emacs -batch -l dunnet'
alias weather='curl wttr.in'

# One of @janmoesen’s ProTips
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
  alias "$method"="lwp-request -m '$method'"
done

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
    alias ql='quick-look'
    alias caskupgrade='for i in $(brew cask list); do brew cask install -f $i; done'
    ;;
esac
