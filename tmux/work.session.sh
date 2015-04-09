if initialize_session "Work"; then
  load_window "work-sdk-work"
  if [[ `hostname -s` = spf-mac-d ]]; then
    load_window "work-ios-viewers"
  fi
  load_window "work-dotfiles-etc"
  select_window 1
fi
finalize_and_go_to_session
