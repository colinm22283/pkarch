BUILD_DIR=build
SRC_DIR=../../dsn

IVFLAGS+=-Wall 
IVFLAGS+=-Wfloating-nets
IVFLAGS+=-I $(SRC_DIR)
IVFLAGS+=-s $(TOP_LEVEL)

HDL_FILES+=defs.v

HDL_FILES+=busint.v
HDL_FILES+=busterm.v

HDL_FILES+=ram.v
HDL_FILES+=dma.v

HDL_FILES_FULL=$(foreach h, $(HDL_FILES), $(SRC_DIR)/$h)

.PHONY: run
run: $(BUILD_DIR)/wave.vcd

.PHONY: wave
wave: $(BUILD_DIR)/wave.vcd
	gtkwave $(BUILD_DIR)/wave.vcd
	
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

$(BUILD_DIR)/logger.v:
	mkdir -p $(@D)
	
	echo 'module logger_m(); initial begin' > $@
	echo '$$dumpfile("$(BUILD_DIR)/wave.vcd");' >> $@
	echo '$$dumpvars(0, $(TOP_LEVEL));' >> $@
	echo 'end endmodule' >> $@

$(BUILD_DIR)/vvp: $(BUILD_DIR)/logger.v $(TB_SRC) $(HDL_FILES_FULL)
	mkdir -p $(@D)
	iverilog $(IVFLAGS) -o $@ $(BUILD_DIR)/logger.v $(TB_SRC) $(HDL_FILES_FULL)

$(BUILD_DIR)/wave.vcd: $(BUILD_DIR)/vvp
	vvp $(BUILD_DIR)/vvp
