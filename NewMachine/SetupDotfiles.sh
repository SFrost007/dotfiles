#!/bin/bash

# Simple script to create symlinks for all supplied dotfiles.
# TODO: Should this safely delete the old versions of these files?
dir=$(pwd)/..

# Set up user-based config files
ln -sf "$dir/aliases" ~/.aliases
ln -sf "$dir/bashrc" ~/.bashrc
ln -sf "$dir/bashprofile" ~/.bash_profile
ln -sf "$dir/functions" ~/.functions
ln -sf "$dir/gitconfig" ~/.gitconfig
ln -sf "$dir/path" ~/.path
ln -sf "$dir/rvmrc" ~/.rvmrc
ln -sf "$dir/sshconfig" ~/.ssh/config
ln -sf "$dir/vimrc" ~/.vimrc
ln -sf "$dir/zprofile" ~/.zprofile
ln -sf "$dir/zshrc" ~/.zshrc

# Set up global config files
# TODO: Delete previous hosts file - requires sudo
ln -sf "$dir/hosts" /etc/hosts
