#!/bin/zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh
export DOTFILES_DIR=$HOME/.dotfiles

# Set name of the theme to load - Powerlevel10k has its own config (.p10k.zsh)
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set the default user based on the hostnames of computers I use
case $(hostname) in
	Simons-MacBook.local|Simons-MacBook-Pro.local)
		DEFAULT_USER="simon";;
esac

# Set some ZSH/oh-my-zsh options
DISABLE_AUTO_TITLE="true"
COMPLETION_WAITING_DOTS="true"
HYPHEN_INSENSITIVE="true"
ZSH_CUSTOM=$DOTFILES_DIR/zsh/omz-custom
setopt PUSHDSILENT

# Load oh-my-zsh plugins
plugins=(
	alias-tips
	colored-man-pages
	#gcloud
	z
	zsh-autosuggestions
	zsh-syntax-highlighting
)
if [[ $(uname) == 'Darwin' ]]; then
	plugins+=(
		xcode
	)
fi

source $ZSH/oh-my-zsh.sh

# Load all .zsh files within this folder
for file in ${DOTFILES_DIR}/zsh/*-*.zsh; do source $file; done

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
