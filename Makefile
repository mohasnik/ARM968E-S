IVERILOG ?= iverilog
VVP      ?= vvp

TOP       ?= ARM_TB
BUILD_DIR ?= build
OUT       := $(BUILD_DIR)/$(TOP).out

TB := testnbenches/ARM_TB.v

SRC := \
	ARM_Datapath.v \
	ARM_Controller.v \
	Condition_Check.v \
	stages/IF_stage.v \
	stages/ID_Stage.v \
	stages/EXE_Stage.v \
	stages/MEM_Stage.v \
	stages/WB_Stage.v \
	stages/Hazard_Unit.v \
	stages/Forwarding_Unit.v \
	primitives/MUX.v \
	primitives/registers/FlipFlop.v \
	primitives/registers/RegFile.v \
	primitives/registers/Status_reg.v \
	primitives/operators/ALU.v \
	primitives/operators/Adder.v \
	primitives/operators/rotational_shifter.v \
	primitives/val2_Generator.v \
	primitives/memories/instruction_memory.v \
	primitives/memories/SRAM_CT.v \
	primitives/memories/sram_sim.v \
	primitives/memories/cache.v

.PHONY: all run clean

all: $(OUT)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(OUT): $(TB) $(SRC) | $(BUILD_DIR)
	$(IVERILOG) -g2012 -Wall -s $(TOP) -o $(OUT) $(TB) $(SRC)

run: $(OUT)
	$(VVP) -n $(OUT)

clean:
	rm -rf $(BUILD_DIR)