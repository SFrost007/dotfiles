#!/bin/bash

# Simple script to create symlinks for all supplied dotfiles.
# TODO: Should this safely delete the old versions of these files?
dir=$(pwd)

# Set up user-based config files
ln -s "$dir/config" ~/.config
ln -sf "$dir/aliases" ~/.aliases
ln -sf "$dir/bashrc" ~/.bashrc
ln -sf "$dir/bashprofile" ~/.bash_profile
ln -sf "$dir/exports" ~/.exports
ln -sf "$dir/functions" ~/.functions
ln -sf "$dir/gitconfig" ~/.gitconfig
ln -sf "$dir/gitignore_global" ~/.gitignore_global
ln -sf "$dir/path" ~/.path
ln -sf "$dir/rvmrc" ~/.rvmrc
ln -sf "$dir/Breakpoints_v2.xcbkptlist" ~/Library/Developer/Xcode/UserData/xcdebugger
if [ -f $dir/sshconfig ]; then
	mkdir -p ~/.ssh
	ln -sf "$dir/sshconfig" ~/.ssh/config
	chmod 600 ~/.ssh/config
fi
ln -sf "$dir/tmux.conf" ~/.tmux.conf
ln -sf "$dir/vimrc" ~/.vimrc
ln -sf "$dir/zprofile" ~/.zprofile
ln -sf "$dir/zshrc" ~/.zshrc

