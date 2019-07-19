#!/bin/bash

_module_friendlyname() {
  echo "Link dotfiles"
}

_module_run_after_git_pull() {
  return 0 # YES
}

_module_valid() {
  return 0 # YES (Always valid)
}

link_file() {
  local src=$1 dst=$2
  local overwrite= backup= skip= action=

  # Protect against doing something unintended and destructive, like removing a
  # directory when trying to link a file and choosing "Overwrite"
  if [[ -d "$dst" && ! -d "$src" ]]; then
    echo "Linking source file to destination directory not supported"; return 1
  fi

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]; then

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]; then

      local currentSrc=`readlink "$dst"`

      if [ "$currentSrc" == "$src" ]; then
        skip=true;
      else
        prompt "File already exists: $(basename "$dst"). [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action
        echo ""

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

_module_exec() {
  local TARGET_DIR=$HOME
  local overwrite_all=false backup_all=false skip_all=false

  link_file ${DOTFILES_DIR}/git/.gitconfig ${TARGET_DIR}/.gitconfig
  link_file ${DOTFILES_DIR}/rtv/rtv.cfg ${TARGET_DIR}/.config/rtv/rtv.cfg
  link_file ${DOTFILES_DIR}/rtv/.mailcap ${TARGET_DIR}/.mailcap
  link_file ${DOTFILES_DIR}/tmux/oh-my-tmux/.tmux.conf ${TARGET_DIR}/.tmux.conf
  link_file ${DOTFILES_DIR}/tmux/.tmux.conf.local ${TARGET_DIR}/.tmux.conf.local
  link_file ${DOTFILES_DIR}/twterm ${TARGET_DIR}/.twterm
  link_file ${DOTFILES_DIR}/vim/.vimrc ${TARGET_DIR}/.vimrc
  link_file ${DOTFILES_DIR}/vim/.vim ${TARGET_DIR}/.vim
  link_file ${DOTFILES_DIR}/zsh/.zshrc ${TARGET_DIR}/.zshrc
  link_file ${DOTFILES_DIR}/zsh/.zshenv ${TARGET_DIR}/.zshenv

  mkdir -p ${TARGET_DIR}/.ssh
  link_file ${DOTFILES_DIR}/ssh/config ${TARGET_DIR}/.ssh/config
  link_file ${DOTFILES_DIR}/ssh/config.d ${TARGET_DIR}/.ssh/config.d
  link_file ${DOTFILES_DIR}/ssh/cloudssh_bookmarks ${TARGET_DIR}/.ssh/cloudssh_bookmarks
}

