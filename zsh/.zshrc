#!/bin/zsh

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh
export DOTFILES_DIR=$HOME/.dotfiles

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

# Set some ZSH/oh-my-zsh options
DISABLE_AUTO_TITLE="true"
COMPLETION_WAITING_DOTS="true"
HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="true"
ZSH_CUSTOM=$DOTFILES_DIR/zsh/omz-custom

# Load oh-my-zsh plugins
plugins=(
	colored-man-pages
	colorize
	encode64
	sudo
	z
)
if [[ $(uname) == 'Darwin' ]]; then
	plugins+=(
		osx
		xcode
	)
fi

source $ZSH/oh-my-zsh.sh

# Load all .zsh files within this folder
for file in ${DOTFILES_DIR}/zsh/*.zsh; do source $file; done
