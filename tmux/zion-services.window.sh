new_window "Services"

split_h 50

select_pane 1
run_cmd "cd /etc/apache2/sites-enabled"
split_v 50
run_cmd "cd ~"

select_pane 3
run_cmd "cd ~/.sickbeard"
split_v 50
run_cmd "cd ~/.couchpotato"
