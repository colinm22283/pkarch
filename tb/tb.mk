BUILD_DIR=build

$(BUILD_DIR)/sim.cpp:
	mkdir -p $(@D)
	
	echo '#include "V$(TOP_LEVEL).h"' > $@
	echo '#include "verilated.h"' >> $@
	echo '#include "verilated_fst_c.h"' >> $@
	echo 'int main(int argc, char** argv) {' >> $@
	echo 'VerilatedContext* contextp = new VerilatedContext;' >> $@
	echo 'VerilatedFstC* tfp = nullptr;' >> $@
	echo 'Verilated::traceEverOn(true);' >> $@
	echo 'tfp = new VerilatedFstC;' >> $@
	echo 'contextp->commandArgs(argc, argv);' >> $@
	echo 'V$(TOP_LEVEL)* top = new V$(TOP_LEVEL){contextp};' >> $@
	echo 'top->trace(tfp, 99);' >> $@
	echo 'tfp->open("$(BUILD_DIR)/out.fst");' >> $@
	echo 'while (!contextp->gotFinish()) {' >> $@
	echo 'top->eval();' >> $@
	echo 'tfp->dump(contextp->time());' >> $@
	echo 'contextp->timeInc(1);' >> $@
	echo '}' >> $@
	echo 'tfp->close();' >> $@
	echo 'delete top;' >> $@
	echo 'delete contextp;' >> $@
	echo 'return 0;' >> $@
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

.PHONY: build
build: $(BUILD_DIR)/out

.PHONY: run
run: build
	./$(BUILD_DIR)/out

.PHONY: wave
wave: run
	$(WAVE) $(BUILD_DIR)/out.fst

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	
