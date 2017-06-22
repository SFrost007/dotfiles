# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh
DOTFILES=$HOME/.dotfiles

# Set name of the theme to load.
ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_MODE='awesome-patched'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context background_jobs dir)
POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status vcs time)
POWERLEVEL9K_STATUS_VERBOSE=false
POWERLEVEL9K_DIR_HOME_FOREGROUND="white"
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND="white"
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND="white"

# Set the default user based on the hostnames of computers I use
case $(hostname) in
	(Simons-MacBook.local)	DEFAULT_USER="simon";;
	(BURCEI.realvnc.ltd)	DEFAULT_USER="spf";;
esac

# Uncomment following line if you want to disable autosetting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under

plugins=(
	colored-man-pages
	colorize
	encode64
	sudo
	z
)

# Only include the Xcode plugin on OS X
if [[ $(uname) == 'Darwin' ]]; then
	plugins+=(
		osx
		xcode
	)
fi


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
# My scripts
addPathDir $DOTFILES/bin


###########################################################
# Change Dir override                                     #
# Lists contents of directory & runs git status for repos #
###########################################################
function chpwd() {
	emulate -L zsh
	# List the items if there aren't too many (2 * window
	# height), otherwise show in the non-list mode.
	if (( `ls -l | wc -l` > `tput lines`/2 )); then
		ls -AG
	else
		ls -lAhG
	fi
	echo ''
	if [[ -e ".git" ]] && [[ $(git status -s) ]]; then
		echo "$fg_bold[white]Git status $reset_color"
		git status -s
		echo '' 
	fi
}


###########################################################
# Load external scripts for extra functionality           #
###########################################################
source $DOTFILES/zsh/aliases.sh
source $DOTFILES/zsh/exports.sh
source $ZSH/oh-my-zsh.sh
