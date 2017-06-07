#!/bin/bash

# TODO: Read these from some config file
SOURCE_DIR=~/.dotfiles
TARGET_DIR=~

ln -sf ${SOURCE_DIR}/bash/.bashrc ${TARGET_DIR}
ln -sf ${SOURCE_DIR}/git/.gitconfig ${TARGET_DIR}
ln -sf ${SOURCE_DIR}/tmux/oh-my-tmux/.tmux.conf ${TARGET_DIR}
ln -sf ${SOURCE_DIR}/tmux/.tmux.conf.local ${TARGET_DIR}
ln -sf ${SOURCE_DIR}/vim/.vimrc ${TARGET_DIR}
ln -sf ${SOURCE_DIR}/vim/.vim ${TARGET_DIR}
ln -sf ${SOURCE_DIR}/zsh/.zshrc ${TARGET_DIR}