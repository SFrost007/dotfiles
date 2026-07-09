#!/bin/zsh

###########################################################
# Change Dir override                                     #
# Lists contents of directory & runs git status for repos #
###########################################################
function chpwd() {
  emulate -L zsh

  # Don't auto-list when Claude Code (or another agent) is driving the shell.
  [[ -n "$CLAUDECODE" || -n "$CLAUDE_CODE_ENTRYPOINT" ]] && return
  # And also when there's no stdout (e.g. scripts, pipes, etc)
  [[ -t 1 ]] || return


  # List the items if there aren't too many (2 * window
  # height), otherwise show in the non-list mode.
  if (( `ls -l | wc -l` > `tput lines`/2 )); then
    ls -A
  else
    ls -lAh
  fi
  echo ''
  if [[ -e ".git" ]] && [[ $(git status -s) ]]; then
    echo "$fg_bold[white]Git status $reset_color"
    git status -s
    echo '' 
  fi
}
