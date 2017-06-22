# General shortcuts
alias cls='clear'
alias du='du -h'
alias cp='rsync --progress -ah'
alias ccat='colorize'
alias shutdown='sudo shutdown -h now'

# Useful stuff
alias myip='ifconfig | grep broadcast | awk -F " " '"'"'{print $2}'"'"
alias sedrecurse='find . -type f -print | xargs sed -i ""'

# Web-dev related stuff
alias serve='python -m SimpleHTTPServer &'
alias stopserve='pkill -f SimpleHTTPServer'

# Source control
alias gitcompress='git repack && git prune'

# Fun stuff
alias adventure='emacs -batch -l dunnet'

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
    ;;
esac
