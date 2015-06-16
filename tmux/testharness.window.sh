new_window "TestHarness"

run_cmd "cd ~/Code/WorkProjects/sdkautotest/python/tools/"
run_cmd "python ./agent.py"

split_h 50

# Ready to run tests
select_pane 2
run_cmd "cd ~/Code/WorkProjects/sdkautotest/"
# run_cmd "./tests.sh spf.ios tests/test_examples.py"
