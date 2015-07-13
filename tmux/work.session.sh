if initialize_session "Work"; then
  if [[ `hostname -s` = spf-mac-d ]]; then
    #load_window "work-idroid"
    load_window "work-ios-viewers"
  else
    load_window "work-sdk-work"
  fi
  load_window "work-dotfiles-etc"
  select_window 1
fi
finalize_and_go_to_session
