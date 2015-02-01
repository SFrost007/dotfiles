new_window "Media"

split_h 50

select_pane 1
run_cmd "cd ~/Downloads/complete"
split_v 50
run_cmd "cd /storage/Transmission/complete"

select_pane 3
run_cmd "cd /storage/Media/Movies"
split_v 50
run_cmd "cd /storage/Media/TV\ Programs"
