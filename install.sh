#!/bin/bash
set -e

##############################################################################
# Set default paths (if not already set in ENVs)
##############################################################################
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
OHMYZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
DOTFILES_TOOLS_DIR="${DOTFILES_DIR}/dotfiles"
title_count=1

# TODO: This fails if DOTFILES_DIR doesn't exist..
source "${DOTFILES_TOOLS_DIR}/inc/funcs.sh"

main() {
  check_if_first_run

  printf "\033[1m\033[41m\033[97m
                            __      __  _____ __                                
                       ____/ /___  / /_/ __(_) /__  _____                       
                      / __  / __ \/ __/ /_/ / / _ \/ ___/                       
                     / /_/ / /_/ / /_/ __/ / /  __(__  )                        
                     \__,_/\____/\__/_/ /_/_/\___/____/                         
\033[0m
  "

  title "Pre-checks..."
  print_os_info

  if is_online; then
    print_success "Internet connection is online"
  else
    exit_with_message "Internet connection is offline"
  fi

  ##############################################################################
  # Install macOS Command Line Tools (inc. git) if not already done
  ##############################################################################
  if is_mac; then
    if file_exists "/Library/Developer/CommandLineTools/usr/bin/git"; then
      print_success "Command Line Tools installed"
    else
      print_info "Requesting install of Xcode Command Line Tools"
      xcode-select --install
      print_waiting
    fi
  fi

  ##############################################################################
  # Download and extract the repo contents if we're running the script remotely
  ##############################################################################
  if dir_exists "$DOTFILES_DIR"; then
    print_success "Dotfiles dir exists"
  else
    print_info "╭───────────────────────────────────────────────────────────────╮"
    print_info "│ It looks like this is the first time you're using dotfiles.   │"
    print_info "│                                                               │"
    print_info "│ This script runs mostly without prompts, and automatically    │"
    print_info "│ installs/configures software as defined in the config files in│"
    print_info "│ the repository. You should be sure this is what you want!     │"
    print_info "╰───────────────────────────────────────────────────────────────╯"
    if ! ask "Are you sure you want to continue?"; then
      print_info "OK, bye!\n" && exit 0
    fi

    if command_exists "git"; then
      print_info "Using git to clone into ${DOTFILES_DIR}"

      if ssh_key_exists; then
        print_success "Existing SSH key found"
      else
        if ask "No SSH key found. Create one?"; then
          create_ssh_key
        fi
      fi

      if ssh_key_exists; then
        CLONE_WITH_SSH=1
        if ask "Copy SSH key to the clipboard (to add to Github)?"; then
          copy_ssh_key_and_open_github
        fi
      fi

      if [[ $CLONE_WITH_SSH -eq 1 ]]; then
        REPO_URL="git@github.com:SFrost007/dotfiles.git"
      else
        print_warning "Cloning dotfiles via HTTPS, updates cannot be committed back."
        REPO_URL="https://github.com/SFrost007/dotfiles.git"
      fi
      print_info "Cloning dotfiles repo from ${REPO_URL}..."
      git clone --recursive --quiet "${REPO_URL}" "${DOTFILES_DIR}"
    else
      print_info "Git does not exist, downloading dotfiles.zip from Github..."
      print_warning "Cloning via SSH is recommended; this method excludes submodules."
      print_waiting
      curl -fsSL https://github.com/SFrost007/dotfiles/archive/master.zip > dotfiles.zip
      print_info "Extracting..."
      unzip -q dotfiles.zip && mv dotfiles-master "${DOTFILES_DIR}" && rm dotfiles.zip
      print_warning "TODO: Set git origin for dotfiles directory once git exists"
    fi
  fi
  pushd "$DOTFILES_DIR" >/dev/null

  prompt_for_computer_type_if_not_set
  print_computer_type


  title "Core tools..."
  ##############################################################################
  # Homebrew
  ##############################################################################
  if is_mac; then
    source "${DOTFILES_TOOLS_DIR}/macOS/install_homebrew.sh"
  else
    print_info "Not macOS, skipping Homebrew"
  fi

  ##############################################################################
  # oh-my-zsh
  ##############################################################################
  if dir_exists "${OHMYZSH_DIR}"; then
    print_success "oh-my-zsh already installed"
  else
    source "${DOTFILES_TOOLS_DIR}/install_ohmyzsh.sh"
  fi

  ##############################################################################
  # Submodules update
  ##############################################################################
  if command_exists "git"; then
    print_info "Updating submodules..."
    git submodule update --init
  else
    print_warning "Skipping submodule update as 'git' does not exist"
  fi

  ##############################################################################
  # Link dotfiles
  ##############################################################################
  source "${DOTFILES_TOOLS_DIR}/link_dotfiles.sh"
  # Load environment variables for the rest of the script
  source "${DOTFILES_DIR}/zsh/20-exports.zsh"


  ##############################################################################
  # Packages
  ##############################################################################
  if is_mac; then
    source "${DOTFILES_TOOLS_DIR}/packages/install_brews.sh"
    source "${DOTFILES_TOOLS_DIR}/packages/install_mas_apps.sh"
  elif is_linux; then
    print_warning "TODO: Install apt packages"
  fi
  # General packages
  source "${DOTFILES_TOOLS_DIR}/packages/install_npms.sh"
  source "${DOTFILES_TOOLS_DIR}/packages/install_gems.sh"


  title "Finishing touches..."
  ##############################################################################
  # Set zsh as shell
  ##############################################################################
  if [[ $(echo $SHELL) =~ "zsh" ]]; then
    print_success "ZSH already set as shell"
  elif [[ $(cat /etc/shells | grep -e "/zsh$") ]]; then
    print_info "Setting shell to ZSH..."
    chsh -s $(grep /zsh$ /etc/shells | tail -1)
    print_success "ZSH will be the default shell on the next session."
  else
    print_warning "ZSH is not installed, not changing shell"
  fi


  ##############################################################################
  # Font handling
  ##############################################################################
  source "${DOTFILES_TOOLS_DIR}/install_fonts.sh"


  ##############################################################################
  # macOS preferences
  ##############################################################################
  if is_mac; then
    if is_first_run; then
      if ask "Set macOS default preferences?"; then
        source "${DOTFILES_TOOLS_DIR}/macOS/setup_defaults.sh"
      fi
      cp "${DOTFILES_TOOLS_DIR}/macOS/Post-Setup TODO.txt" "${HOME}/Desktop"
    else
      print_info "Not first run, skipping macOS defaults script"
    fi
  fi


  ##############################################################################
  # Exit message (figlet -f smslant)
  ##############################################################################
  _print_in_green "
  ╭──────────────────────────────────────────────────────────────────────────╮
  │              _____             __    __                     __           │
  │             / ___/__  ___  ___/ /   / /____      ___ ____  / /           │
  │            / (_ / _ \/ _ \/ _  /   / __/ _ \    / _ '/ _ \/_/            │
  │            \___/\___/\___/\_,_/    \__/\___/    \_, /\___(_)             │
  │                                                /___/                     │
  ╰──────────────────────────────────────────────────────────────────────────╯
  \n"
}



################################################################################
# Pre-checks for various conditions
################################################################################

is_online() {
  print_warning "TODO: nc doesn't exist on Raspbian, so this fails.."
  if nc -zw1 google.com 443 &>/dev/null; then return 0; else return 1; fi
}

check_if_first_run() {
  if ! dir_exists "${DOTFILES_DIR}"; then
    FIRST_RUN=1
  fi
}

is_first_run() {
  if [ ! -z ${FIRST_RUN+x} ]; then return 0; else return 1; fi
}

################################################################################
# SSH key handling
################################################################################

SSH_KEY_PATH="${HOME}/.ssh/id_rsa.pub"

ssh_key_exists() {
  if file_exists "${SSH_KEY_PATH}"; then return 0; else return 1; fi
}

create_ssh_key() {
  print_info "No SSH key found. Creating one..."
  ssh-keygen -t rsa
}

offer_copy_ssh_key_for_github() {
  if ask "Copy SSH key (for pasting to Github)?"; then
    copy_ssh_key_and_open_github
  fi
}

copy_ssh_key_and_open_github() {
  if is_mac; then
    cat "${SSH_KEY_PATH}" | pbcopy
    open "https://github.com/account/ssh"
    print_success "Copied to clipboard"
    print_waiting
  else
    print_warning "TODO: Copy SSH key without pbcopy"
  fi
}


################################################################################
# Run script
################################################################################
main
