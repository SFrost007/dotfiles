########################
# Set up prompt format #
########################
PS1='[\h:\w]$ '

#################################
# Enable colours in ls and grep #
#################################
export CLICOLOR=1
export LSCOLORS=Exfxcxdxbxegedabagacad
export GREP_OPTIONS='--color=auto'

############################
# Load other related files #
############################
source ~/.aliases
source ~/.functions
source ~/.path
