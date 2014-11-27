#!/bin/bash

clone_repo() {
	# TODO: This should check whether the repo already exists and avoid attempting
	# to re-clone. Do we want to do a deep inspection and verify that the URL is
	# set as a remote?
	# Maybe also take an optional 2nd argument for the target directory.
	# We could maybe supress the output and use the info()/prompt()/success()
	# functions from install.sh. Though we wouldn't get progress updates..
	git clone "$1"
}

# This should already exist as it's where the dotfiles are stored
mkdir -p ~/Code/TerminalUtils
pushd ~/Code/TerminalUtils/
clone_repo https://github.com/jimeh/tmuxifier.git
popd
