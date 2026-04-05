BUILD_DIR=build
PROG_SRC_DIR=src

AS=riscv32-unknown-elf-as

ASFLAGS+=-march=rv32i
ASFLAGS+=-mabi=ilp32

OBJCOPY=riscv32-unknown-elf-objcopy

TOP_LEVEL=top_tb
TB_SRCS=$(TOP_LEVEL).sv

$(BUILD_DIR)/sim.cpp:
	mkdir -p $(@D)
	
	echo '#include "V$(TOP_LEVEL).h"' > $@
	echo '#include "verilated.h"' >> $@
	echo '#include "verilated_vcd_c.h"' >> $@
	echo 'int main(int argc, char** argv) {' >> $@
	echo 'VerilatedContext* contextp = new VerilatedContext;' >> $@
	echo 'VerilatedVcdC* tfp = nullptr;' >> $@
	echo 'Verilated::traceEverOn(true);' >> $@
	echo 'tfp = new VerilatedVcdC;' >> $@
	echo 'contextp->commandArgs(argc, argv);' >> $@
	echo 'V$(TOP_LEVEL)* top = new V$(TOP_LEVEL){contextp};' >> $@
	echo 'top->trace(tfp, 99);' >> $@
	echo 'tfp->open("$(BUILD_DIR)/out.vcd");' >> $@
	echo 'while (!contextp->gotFinish()) {' >> $@
	echo 'contextp->timeInc(1);' >> $@
	echo 'tfp->dump(contextp->time());' >> $@
	echo 'top->eval();' >> $@
	echo '}' >> $@
	echo 'tfp->close();' >> $@
	echo 'delete top;' >> $@
	echo 'delete contextp;' >> $@
	echo 'return 0;' >> $@
	echo '}' >> $@

$(BUILD_DIR)/out: $(BUILD_DIR)/sim.cpp $(DSN_SRCS) $(TB_SRCS) $(HEADERS)
	$(VERILATOR) \
		$(VFLAGS) \
		--trace-vcd \
		--cc \
		--exe \
		--build \
		--top-module $(TOP_LEVEL) \
		-I$(INCLUDE_DIR) \
		--Mdir $(BUILD_DIR) \
		-o out \
		$(BUILD_DIR)/sim.cpp \
		$(DSN_SRCS) \
		$(TB_SRCS)

$(BUILD_DIR)/prog.o: $(PROG_SRC_DIR)/$(PROG_NAME).s .FORCE
	mkdir -p $(@D)
	$(AS) -c $(ASFLAGS) $< -o $@

$(BUILD_DIR)/prog.bin: $(BUILD_DIR)/prog.o
	mkdir -p $(@D)
	$(OBJCOPY) -O binary $< $@

.PHONY: build
build: $(BUILD_DIR)/out $(BUILD_DIR)/prog.bin

.PHONY: run
run: build
	./$(BUILD_DIR)/out

.PHONY: wave
wave: run
	$(GTKWAVE) $(BUILD_DIR)/out.vcd

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	
.FORCE:

