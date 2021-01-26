#!/bin/sh
#
# Symlinks all defined dotfiles into place, with some platform-specific additions.
# Each line in FILES_TO_LINK denotes a pair of filenames; the first is used as
# the source path and the second the destination.

source "${BASH_SOURCE%/*}/inc/funcs.sh"

TARGET_DIR="${HOME}"
FILES_TO_LINK=(
  "${DOTFILES_DIR}/git/.gitconfig"                "${TARGET_DIR}/.gitconfig"
  "${DOTFILES_DIR}/rtv/.mailcap"                  "${TARGET_DIR}/.mailcap"
  "${DOTFILES_DIR}/rtv/rtv.cfg"                   "${TARGET_DIR}/.config/rtv/rtv.cfg"
  "${DOTFILES_DIR}/ssh/config"                    "${TARGET_DIR}/.ssh/config"
  "${DOTFILES_DIR}/ssh/config.d"                  "${TARGET_DIR}/.ssh/config.d"
  "${DOTFILES_DIR}/tmux/oh-my-tmux/.tmux.conf"    "${TARGET_DIR}/.tmux.conf"
  "${DOTFILES_DIR}/tmux/.tmux.conf.local"         "${TARGET_DIR}/.tmux.conf.local"
  "${DOTFILES_DIR}/vim/.vimrc"                    "${TARGET_DIR}/.vimrc"
  "${DOTFILES_DIR}/vim/.vim"                      "${TARGET_DIR}/.vim"
  "${DOTFILES_DIR}/zsh/.zshrc"                    "${TARGET_DIR}/.zshrc"
  "${DOTFILES_DIR}/zsh/.p10k.zsh"                 "${TARGET_DIR}/.p10k.zsh"
  "${DOTFILES_DIR}/zsh/.zshenv"                   "${TARGET_DIR}/.zshenv"
  "${DOTFILES_DIR}/zsh/.hushlogin"                "${TARGET_DIR}/.hushlogin"
)

if is_mac; then
  XCUSERDATA="${TARGET_DIR}/Library/Developer/Xcode/UserData"
  SUBLIME_PACKAGES_DIR="${TARGET_DIR}/Library/Application Support/Sublime Text 3/Packages"
  FILES_TO_LINK+=(
    "${DOTFILES_DIR}/sublime/"                  "${SUBLIME_PACKAGES_DIR}/User"
    "${DOTFILES_DIR}/Xcode/xcdebugger"          "${XCUSERDATA}/xcdebugger"
    "${DOTFILES_DIR}/Xcode/FontAndColorThemes"  "${XCUSERDATA}/FontAndColorThemes"
    "${DOTFILES_DIR}/Xcode/KeyBindings"         "${XCUSERDATA}/KeyBindings"
  )
fi


# "Main" function, called at end of script
_link_dotfiles() {
  title "Linking dotfiles..."
  local overwrite_all=false backup_all=false skip_all=false
  for (( i=0; i<${#FILES_TO_LINK[@]}; i+=2 )); do
    SRC="${FILES_TO_LINK[i]}"
    DST="${FILES_TO_LINK[i+1]}"
    TARGET_DIR=$(dirname "$DST")
    mkdir -p "${TARGET_DIR}"
    link_file "${SRC}" "${DST}"
  done
  print_if_skipped $symlink_skip_count "symlinks"
}


# Helper function to handle linking a single file semi-interactively
link_file() {
  local src=$1 dst=$2
  local overwrite= backup= skip= action=

  # Protect against doing something unintended and destructive, like removing a
  # directory when trying to link a file and choosing "Overwrite"
  if [[ -d "$dst" && ! -d "$src" ]]; then
    print_error "Linking source file to destination directory not supported"; return 1
  fi

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]; then
    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]; then
      local currentSrc=`readlink "$dst"`
      if [ "$currentSrc" == "$src" ]; then
        skip=true;
      else
        _print_in_white " ❓  File already exists: $(basename "$dst").\n     [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all? "
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
    print_deleted "Removed $dst"
  fi

  if [ "$backup" == "true" ]; then
    mv "$dst" "${dst}.bak"
    print_success "Moved $dst to ${dst}.bak"
  fi

  if [ "$skip" == "true" ]; then
    symlink_skip_count=$((symlink_skip_count+1))
    #print_info "Skipped $dst"
  fi

  # Actually create the symlink if required
  if [ "$skip" != "true" ]; then
    ln -s "$src" "$dst"
    print_success "Created $dst"
  fi
}

# Run script
symlink_skip_count=0
_link_dotfiles
