SV2V = sv2v
YOSYS = yosys
VERILATOR = verilator
CXX = g++

SV_DIR = rtl
V_DIR = gen
TB_DIR = tb
CPP_DIR = cpp
OBJ_DIR = obj
SYN_DIR = syn
SCA_DIR = sca

VERILATOR_FLAGS = --Mdir $(OBJ_DIR) -CFLAGS -I$(shell pwd)/$(CPP_DIR) -cc -sv -I$(SV_DIR) --exe --build -Wall -O0
VERILATOR_SYN_FLAGS = --Mdir $(OBJ_DIR) -CFLAGS -I$(shell pwd)/$(CPP_DIR) -cc --exe --build -Wall -Wno-unused -Wno-declfilename -Wno-unoptflat -Wno-undriven -O0

YOSYS_LOG_SUFFIX = __log.txt

SV_PACKAGE = $(SV_DIR)/dev_package.sv
SOURCES = $(wildcard $(SV_DIR)/*.sv)
SV_FILES = $(filter-out $(SV_PACKAGE), $(SOURCES))
V_FILES = $(patsubst $(SV_DIR)/%.sv, $(V_DIR)/%.v,$(SV_FILES))
CPP_FILES = $(wildcard $(CPP_DIR)/*.cpp)
SIM_FILES = $(patsubst $(SV_DIR)/%.sv, $(OBJ_DIR)/V%,$(SV_FILES))

TOP_MODULE = ascon_sbox

DEFAULT_NUM_SHARES = 2
# DEFAULT_LATENCY = 1

NUM_SHARES ?= $(DEFAULT_NUM_SHARES)
# LATENCY    ?= $(DEFAULT_LATENCY)

LIBERTY_FILE = stdcells.lib

.PHONY = all sv2v clean test_% syn_%

all: $(OUTPUT_FILE) $(SIM_FILES)

$(V_DIR) $(OBJ_DIR) $(SYN_DIR):
	mkdir -p $@

# .PRECIOUS: $(V_DIR)/%.v
$(V_DIR)/%.v: $(SV_DIR)/%.sv $(SV_FILES) $(V_DIR)
	$(SV2V) -I $(SV_DIR) $< > $@

$(OBJ_DIR)/Vmasked%: VERILATOR_DEFINES = -pvalue+NUM_SHARES=$(NUM_SHARES) -CFLAGS -DNUM_SHARES=$(NUM_SHARES) 
# $(OBJ_DIR)/Vmasked_ascon%: VERILATOR_DEFINES += -pvalue+LATENCY=$(LATENCY)             -CFLAGS -DLATENCY=$(LATENCY) 

$(OBJ_DIR)/Vsyn_masked%: VERILATOR_DEFINES = -CFLAGS -DNUM_SHARES=$(NUM_SHARES)
# $(OBJ_DIR)/Vsyn_masked_ascon%: VERILATOR_DEFINES += -CFLAGS -DLATENCY=$(LATENCY)

$(OBJ_DIR)/V%: $(SV_DIR)/%.sv $(TB_DIR)/tb_%.cpp $(CPP_FILES)
	$(VERILATOR) $(VERILATOR_DEFINES) $(VERILATOR_FLAGS) $^ --top-module $$(basename -s .sv $<)

syn_masked%: YOSYS_DEFINES = NUM_SHARES=$(NUM_SHARES)
# syn_masked_ascon_sbox%: YOSYS_DEFINES += LATENCY=$(LATENCY)

syn_masked%: YOSYS_LOG_SUFFIX = $(NUM_SHARES)_log.txt
syn_%: $(V_DIR)/%.v $(SYN_DIR)
	$(YOSYS_DEFINES) IN_FILES="$<" TOP_MODULE="$$(basename -s .v $<)" OUT_BASE="$(SYN_DIR)/$@" LIBERTY="$(LIBERTY_FILE)" $(YOSYS) synth.tcl -t -l "$(SYN_DIR)/$@_$(YOSYS_LOG_SUFFIX)"

$(OBJ_DIR)/Vsyn_masked%: syn_masked% $(TB_DIR)/tb_masked%.cpp $(CPP_FILES)
	$(VERILATOR) $(VERILATOR_DEFINES) $(VERILATOR_SYN_FLAGS) $(SYN_DIR)/$<_$(NUM_SHARES)_pre.v $(wordlist 2,$(words $^),$^) --top-module $$(echo $< | sed 's/^syn_//') -o $(shell pwd)/$@
$(OBJ_DIR)/Vsyn_%: syn_% $(TB_DIR)/tb_%.cpp $(CPP_FILES)
	$(VERILATOR) $(VERILATOR_DEFINES) $(VERILATOR_SYN_FLAGS) $(SYN_DIR)/$<__pre.v $(wordlist 2,$(words $^),$^) --top-module $$(echo $< | sed 's/^syn_//') -o $(shell pwd)/$@

sca_masked%: syn_masked% $(SCA_DIR)/sca_masked%.cpp
	cmake -B sca/build sca -DNUM_SHARES=$(NUM_SHARES)
	cmake --build sca/build --target $@

clean:
	rm -rf $(V_DIR) $(OBJ_DIR) $(SYN_DIR)