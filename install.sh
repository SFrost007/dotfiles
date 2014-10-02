#!/bin/bash
#
# Installs all dotfiles
#
# Based on Holman does dotfiles (https://github.com/holman/dotfiles/blob/master/script/bootstrap)

DOTFILES_ROOT=$(pwd)


info () {
  printf "  [ \033[00;34m..\033[0m ] $1"
}

prompt () {
  printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}


link_file() {
	local src=$1 dst=$2
	local overwrite= backup= skip= action=

	if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]; then

		if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]; then

			local currentSrc=`readlink "$dst"`

			if [ "$currentSrc" == "$src" ]; then
				skip=true;
			else
				prompt "File already exists: $(basename "$dst"). [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
				read -n 1 action

				case "$action" in
					o )
						overwrite=true;;
					O )
						overwrite_all=true;;
					b )
						backup=true;;
					B )
						backup_all=true;;
					s )
						skip=true;;
					S )
						skip_all=true;;
					* )
						;;
				esac
			fi
		fi
	fi

	overwrite=${overwrite:-$overwrite_all}
	backup=${backup:-$backup_all}
	skip=${skip:-$skip_all}

	if [ "$overwrite" == "true" ]; then
		rm -rf "$dst"
		success "Removed $dst"
	fi

	if [ "$backup" == "true" ]; then
		mv "$dst" "${dst}.bak"
		success "Moved $dst to ${dst}.bak"
	fi

	if [ "$skip" == "true" ]; then
		success "Skipped $src"
	fi

	# Actually create the symlink if required
	if [ "$skip" != "true" ]; then
		ln -s "$1" "$2"
		success "Linked $1 to $2"
	fi
}


install_dotfiles() {
	info 'Installing dotfiles'

	local overwrite_all=false backup_all=false skip_all=false

	for src in $(find "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink'); do
		dst="$HOME/.$(basename "${src%.*}")"
		link_file "$src" "$dst"
	done
}

install_sshconfig() {
	if [ -f $DOTFILES_ROOT/ssh/config ]; then
		info 'Installing sshconfig'
		mkdir -p ~/.ssh
		local overwrite_all=false backup_all=false skip_all=false
		link_file "$DOTFILES_ROOT"/ssh/config ~/.ssh/config
		chmod 600 ~/.ssh/config
	else
		info 'No SSH config file present, skipping'
		printf "\n"
	fi
}

install_configdirs() {
	info 'Linking config directories'
	mkdir -p ~/.config

	local overwrite_all=false backup_all=false skip_all=false

	for src in $(find "$DOTFILES_ROOT" -maxdepth 2 -name '*.configdir'); do
		dst="$HOME/.config/$(basename "${src%.*}")"
		link_file "$src" "$dst"
	done
}

install_sublime() {
	info 'Linking Sublime Text config'

	local overwrite_all=false backup_all=false skip_all=false
	$(./scripts/AssertOSX);
	if [[ $? -eq 0 ]]; then
		SUBLIME_DIR=${HOME}/Library/Application\ Support/Sublime\ Text\ 2
	else
		SUBLIME_DIR=${HOME}/.config/sublime-text-2
	fi

	mkdir -p ${SUBLIME_DIR}/Packages
	link_file ${DOTFILES_ROOT}/sublime/User ${SUBLIME_DIR}/Packages/User

	if [[ ! -f ${SUBLIME_DIR}/Installed\ Packages/Package\ Control.sublime-package ]]; then
		mkdir -p ${SUBLIME_DIR}/Installed\ Packages
		pushd ${SUBLIME_DIR}/Installed\ Packages > /dev/null
		wget http://sublime.wbond.net/Package%20Control.sublime-package -o /dev/null
		if [[ $? -eq 0 ]]; then
			success 'Installed Package Control for Sublime'
		else
			fail 'Failed to download Package Control'
		fi
		popd > /dev/null
	else
		success 'Skipped installing Package Control - already exists'
	fi
}


install_dotfiles
install_sshconfig
install_configdirs
install_sublime

