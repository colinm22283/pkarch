BUILD_DIR=build
PROG_SRC_DIR=src

AS=riscv32-none-elf-as
CC=riscv32-none-elf-gcc
OBJCOPY=riscv32-none-elf-objcopy
OBJDUMP=riscv32-none-elf-objdump
LD=riscv32-none-elf-ld

NATIVE_CC=cc
DIFF=vimdiff

ARCH=rv32izmmul
ABI=ilp32

COMFLAGS=-c -mabi=$(ABI) -march=$(ARCH)
ASFLAGS=$(COMFLAGS)
LDFLAGS=
VFLAGS+=-Wno-WAITCONST

TOP_LEVEL=top_tb
TB_SRCS=$(TOP_LEVEL).sv

PROGS=$(shell find $(SRC_DIR) -name "*.s" | sed -E 's/[a-zA-Z0-9\/]+\/([a-zA-Z0-9_]+)\.s/\1/')

.PHONY: all
all:
	for p in $(PROGS); do PROG_NAME=$$p $(MAKE) run

.PHONY: clean

.PHONY: run
run: $(BUILD_DIR)/$(PROG_NAME).elf $(BUILD_DIR)/out

$(BUILD_DIR)/sim.cpp:
	mkdir -p $(@D)
	
	echo '#include "V$(TOP_LEVEL).h"' > $@
	echo '#include "verilated.h"' >> $@
	echo '#include "verilated_fst_c.h"' >> $@
	echo '#include <fcntl.h>' >> $@
	echo '#include <unistd.h>' >> $@
	echo 'int main(int argc, char** argv) {' >> $@
	echo '  VerilatedContext* contextp = new VerilatedContext;' >> $@
	echo '  VerilatedFstC* tfp = nullptr;' >> $@
	echo '  Verilated::traceEverOn(true);' >> $@
	echo '  tfp = new VerilatedFstC;' >> $@
	echo '  contextp->commandArgs(argc, argv);' >> $@
	echo '  V$(TOP_LEVEL)* top = new V$(TOP_LEVEL){contextp};' >> $@
	echo '  top->trace(tfp, 99);' >> $@
	echo '  tfp->open("$(BUILD_DIR)/out.fst");' >> $@
	echo '  fcntl(STDIN_FILENO, F_SETFL, O_NONBLOCK);' >> $@
	echo '  while (!contextp->gotFinish()) {' >> $@
	echo '    top->eval();' >> $@
	echo '    tfp->dump(contextp->time());' >> $@
	echo '    contextp->timeInc(1);' >> $@
	echo '  }' >> $@
	echo '  tfp->close();' >> $@
	echo '  delete top;' >> $@
	echo '  delete contextp;' >> $@
	echo '  return 0;' >> $@
	echo '}' >> $@

$(BUILD_DIR)/out: $(BUILD_DIR)/sim.cpp $(DSN_SRCS) $(TB_SRCS) $(HEADERS)
	$(VERILATOR) \
		$(VFLAGS) \
		--trace-fst \
		--trace-structs \
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

$(BUILD_DIR)/$(PROG_NAME).elf: $(BUILD_DIR)/$(PROG_NAME).o linker.ld
	mkdir -p $(@D)
	$(LD) $(LDFLAGS) -T linker.ld $< -o $@

$(BUILD_DIR)/$(PROG_NAME).o: $(PROG_SRC_DIR)/$(PROG_NAME).s
	mkdir -p $(@D)
	$(AS) $(ASFLAGS) $< -o $@

