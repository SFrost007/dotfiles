#!/usr/bin/env bash
set -e

printf "\033[1m\033[41m\033[97m
                            __      __  _____ __                                
                       ____/ /___  / /_/ __(_) /__  _____                       
                      / __  / __ \/ __/ /_/ / / _ \/ ___/                       
                     / /_/ / /_/ / /_/ __/ / /  __(__  )                        
                     \__,_/\____/\__/_/ /_/_/\___/____/                         
\033[0m
"

################################################################################
# Set default path if not already set externally
################################################################################
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
OHMYZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
SETUPTOOLS_DIR="${DOTFILES_DIR}/_install"


################################################################################
# Check dependencies
################################################################################
FUNCS_SCRIPT="${SETUPTOOLS_DIR}/include_funcs.sh"
if [ -e "${FUNCS_SCRIPT}" ]; then
  source "${FUNCS_SCRIPT}"
else
  echo " ⛔️  Functions script does not exist" && exit 1
fi
title "Pre-checks..."

if is_online; then
  print_success "Internet connection is online"
else
  exit_with_message "Internet connection is offline"
fi

_PREVIOUSLY_RUN_FLAG="${SETUPTOOLS_DIR}/.installed"
if check_file_exists "${_PREVIOUSLY_RUN_FLAG}"; then
  print_success "Previously installed dotfiles, skipping confirmation"
else
  print_info "╭───────────────────────────────────────────────────────────────╮"
  print_info "│ It looks like this is the first time you're using dotfiles.   │"
  print_info "│                                                               │"
  print_info "│ This script runs mostly without prompts, and automatically    │"
  print_info "│ installs/configures software as defined in the config files in│"
  print_info "│ the repository. You should be sure this is what you want!     │"
  print_info "╰───────────────────────────────────────────────────────────────╯"
  if ask "Are you sure you want to continue?"; then
    touch "${_PREVIOUSLY_RUN_FLAG}"
  else
    print_info "OK, bye!\n" && exit 0
  fi
fi



title "Core tools..."
################################################################################
# Homebrew
################################################################################
if is_mac; then
  if check_command_exists "brew"; then
    print_success "Homebrew already installed"
  else
    print_info "Installing Homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
else
  print_info "Not macOS, skipping Homebrew"
fi



################################################################################
# oh-my-zsh
################################################################################
if check_dir_exists "${OHMYZSH_DIR}"; then
  print_success "oh-my-zsh already installed"
else
  print_info "Installing oh-my-zsh..."
  git clone -q --depth=1 https://github.com/robbyrussell/oh-my-zsh.git "${OHMYZSH_DIR}"
fi



################################################################################
# SSH key
################################################################################
if check_file_exists "${HOME}/.ssh/id_rsa"; then
  print_success "SSH key exists"
  print_warning "TODO: Add helpers to create SSH key if missing"
else
  print_warning "No SSH key; you may wish to configure one"
fi



################################################################################
# Link dotfiles
################################################################################
symlink_skip_count=0
_link_dotfiles() {
  title "Linking dotfiles..."
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
  link_file ${DOTFILES_DIR}/zsh/.hushlogin ${TARGET_DIR}/.hushlogin

  mkdir -p ${TARGET_DIR}/.ssh
  link_file ${DOTFILES_DIR}/ssh/config ${TARGET_DIR}/.ssh/config
  link_file ${DOTFILES_DIR}/ssh/config.d ${TARGET_DIR}/.ssh/config.d

  if [[ $symlink_skip_count -gt 0 ]]; then
    print_success "Skipped ${symlink_skip_count} existing symlinks"
  fi
}
_link_dotfiles



################################################################################
# Install packages
################################################################################
title "Installing packages..."
if is_mac; then
  print_warning "TODO: Install brew packages"
  print_warning "TODO: Install cask packages"
  print_warning "TODO: Install AppStore apps"
elif is_linux; then
  print_warning "TODO: Install apt packages"
fi
print_warning "TODO: Install npm packages"
print_warning "TODO: Install gem packages"



title "Finishing touches..."
################################################################################
# Set zsh as shell
################################################################################
if [[ $(echo $SHELL) =~ "zsh" ]]; then
  print_success "ZSH already set as shell"
else
  print_info "Setting shell to ZSH..."
  chsh -s $(grep /zsh$ /etc/shells | tail -1)
  print_success "ZSH will be the default shell on the next session."
fi


print_warning "TODO: Install fonts via brew tap caskroom/fonts (or fallbacks)"
#cd ~/Library/Fonts && { curl -O 'https://github.com/Falkor/dotfiles/blob/master/fonts/SourceCodePro+Powerline+Awesome+Regular.ttf?raw=true' ; cd -; }


################################################################################
# macOS preferences
################################################################################
if is_mac; then
  if ask "Set macOS default preferences?"; then
    source "${SETUPTOOLS_DIR}/macos_setup.sh"
  fi
fi


################################################################################
# Exit message (figlet -f smslant)
################################################################################
_print_in_green "
  ╭──────────────────────────────────────────────────────────────────────────╮
  │              _____             __    __                     __           │
  │             / ___/__  ___  ___/ /   / /____      ___ ____  / /           │
  │            / (_ / _ \/ _ \/ _  /   / __/ _ \    / _ \`/ _ \/_/            │
  │            \___/\___/\___/\_,_/    \__/\___/    \_, /\___(_)             │
  │                                                /___/                     │
  ╰──────────────────────────────────────────────────────────────────────────╯
\n"
