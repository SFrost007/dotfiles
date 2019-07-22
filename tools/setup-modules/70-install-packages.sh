#!/usr/bin/env zsh

_module_friendlyname() {
  echo "Install Packages"
}

_module_run_after_git_pull() {
  return 0 # YES
}

_module_valid() {
  return 0 # YES
}

_module_exec() {
  echo "Which additional packages should be installed?"
  echo "1) Home"
  echo "2) Work"
  echo "3) Neither"
  read -p "Enter an option: " EXTRA_PKGS_CHOICE

  _SOURCES=(${DOTFILES_DIR}/packages/*)
  for i in "${_SOURCES[@]}"; do
    source $i
    echo_header "Installing packages from ${PACKAGE_MANAGER_TITLE}"
    if ! check_command_exists ${PACKAGE_MANAGER_INSTALL_CMD%% *}; then
      warn "Package manager ${_RED}${PACKAGE_MANAGER_INSTALL_CMD%% *}${_RESET} not installed"
    else
      case ${EXTRA_PKGS_CHOICE} in
        1) EXTRA_PKGS=( "${PACKAGES_HOME[@]}" );;
        2) EXTRA_PKGS=( "${PACKAGES_WORK[@]}" );;
        *) EXTRA_PKGS=( );;
      esac
      for PKG in "${PACKAGES[@]} ${EXTRA_PKGS[@]}" ; do
        [[ $PACKAGE_MANAGER_NEEDS_SUDO -eq 1 ]] && _CMD_PREFIX="sudo" || _CMD_PREFIX=""
        _INSTALL_CMD="${_CMD_PREFIX} ${PACKAGE_MANAGER_INSTALL_CMD} ${PKG}"
        _CMD_OUTPUT=`${_INSTALL_CMD} 2>&1`
        if [ $? -eq 0 ]; then
          success "${_INSTALL_CMD}"
        else
          warn "Failed to run ${_INSTALL_CMD}:"
          echo "${_CMD_OUTPUT}"
        fi
      done
    fi
    PKM_CMD=
    echo ""
  done
}
