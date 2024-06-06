set IN_FILES       [regexp -all -inline {\S+} $::env(IN_FILES)]
set TOP_MODULE     $::env(TOP_MODULE)
set OUT_BASE       $::env(OUT_BASE)
set LIBERTY        $::env(LIBERTY)

if {[info exists env(NUM_SHARES)]} {
    set NUM_SHARES $::env(NUM_SHARES)
} else {
    set NUM_SHARES ""
}
if {[info exists env(LATENCY)]} {
    set LATENCY $::env(LATENCY)
} else {
    set LATENCY ""
}

set VLOG_PRE_MAP   $OUT_BASE\_$NUM_SHARES\_pre.v
set VLOG_POST_MAP  $OUT_BASE\_$NUM_SHARES\_post.v
set JSON_PRE_MAP   $OUT_BASE\_$NUM_SHARES\_pre.json
set JSON_POST_MAP  $OUT_BASE\_$NUM_SHARES\_post.json
set STATS_FILE     $OUT_BASE\_$NUM_SHARES\_stats.txt

foreach file $IN_FILES {
    yosys read_verilog -defer $file
}

yosys log "NUM_SHARES = $NUM_SHARES"
if {![string equal "" $NUM_SHARES]} {
    yosys chparam -set NUM_SHARES [expr $NUM_SHARES] $TOP_MODULE
}
yosys log "LATENCY = $LATENCY"
if {![string equal "" $LATENCY]} {
    yosys chparam -set LATENCY [expr $LATENCY] $TOP_MODULE
}

yosys synth -top $TOP_MODULE -flatten -noabc
yosys tee -o $STATS_FILE stat
yosys clean

yosys write_verilog $VLOG_PRE_MAP
yosys write_json    $JSON_PRE_MAP

yosys dfflibmap -liberty $LIBERTY
yosys abc -liberty $LIBERTY
yosys clean -purge

yosys write_verilog $VLOG_POST_MAP
yosys write_json    $JSON_POST_MAP
yosys tee -o $STATS_FILE stat -liberty $LIBERTY