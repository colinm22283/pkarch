BUILD_DIR=build
PROG_SRC_DIR=src

AS=riscv32-none-elf-as
CC=riscv32-none-elf-gcc
OBJCOPY=riscv32-none-elf-objcopy
OBJDUMP=riscv32-none-elf-objdump
LD=riscv32-none-elf-ld

ARCH=rv32i
ABI=ilp32

COMFLAGS=-c -march=$(ARCH) -mabi=$(ABI)
ASFLAGS=$(COMFLAGS)
CFLAGS=-O0 $(COMFLAGS) -nostdlib -ffreestanding -I$(LIB_INCLUDEDIR)

TOP_LEVEL=top_tb
TB_SRCS=$(TOP_LEVEL).sv

include lib/lib.mk

$(BUILD_DIR)/sim.cpp:
	mkdir -p $(@D)
	
	echo '#include "V$(TOP_LEVEL).h"' > $@
	echo '#include "verilated.h"' >> $@
	echo '#include "verilated_fst_c.h"' >> $@
	echo 'int main(int argc, char** argv) {' >> $@
	echo '  VerilatedContext* contextp = new VerilatedContext;' >> $@
	echo '  VerilatedFstC* tfp = nullptr;' >> $@
	echo '  Verilated::traceEverOn(true);' >> $@
	echo '  tfp = new VerilatedFstC;' >> $@
	echo '  contextp->commandArgs(argc, argv);' >> $@
	echo '  V$(TOP_LEVEL)* top = new V$(TOP_LEVEL){contextp};' >> $@
	echo '  top->trace(tfp, 99);' >> $@
	echo '  tfp->open("$(BUILD_DIR)/out.fst");' >> $@
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

ifeq ($(wildcard $(PROG_SRC_DIR)/$(PROG_NAME).s),)
$(BUILD_DIR)/$(PROG_NAME).o: $(PROG_SRC_DIR)/$(PROG_NAME).c $(HEADERS)
	mkdir -p $(@D)
	$(CC) $(CFLAGS) $< -o $@

else
$(BUILD_DIR)/$(PROG_NAME).o: $(PROG_SRC_DIR)/$(PROG_NAME).s
	mkdir -p $(@D)
	$(AS) $(ASFLAGS) $< -o $@
endif

$(BUILD_DIR)/$(PROG_NAME).linked.o: $(BUILD_DIR)/$(PROG_NAME).o $(LIB_OBJS) linker.ld
	mkdir -p $(@D)
	$(LD) --no-relax -T linker.ld $< $(LIB_OBJS) -o $@

$(BUILD_DIR)/$(PROG_NAME).bin: $(BUILD_DIR)/$(PROG_NAME).linked.o
	mkdir -p $(@D)
	$(OBJCOPY) -O binary $< $@

.PHONY: build
build: $(BUILD_DIR)/out $(BUILD_DIR)/$(PROG_NAME).bin

.PHONY: run
run: build
	./$(BUILD_DIR)/out +ROM=$(BUILD_DIR)/$(PROG_NAME).bin

.PHONY: wave
wave: run
	$(WAVE) $(BUILD_DIR)/out.fst

.PHONY: disas
disas: $(BUILD_DIR)/$(PROG_NAME).bin
	$(OBJDUMP) -D -b binary -m riscv:rv32 -M no-aliases -EL $(BUILD_DIR)/$(PROG_NAME).bin

.PHONY: objdump
objdump: $(BUILD_DIR)/$(PROG_NAME).bin
	$(OBJDUMP) -d -m riscv:rv32 $(BUILD_DIR)/$(PROG_NAME).linked.o

.PHONY: objdump_all
objdump_all: $(BUILD_DIR)/$(PROG_NAME).bin
	$(OBJDUMP) -D -m riscv:rv32 $(BUILD_DIR)/$(PROG_NAME).linked.o

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	
.FORCE:

