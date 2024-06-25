set IN_FILE     $::env(IN_FILE)
yosys read_json $IN_FILE
yosys show