export TB_DIR=$(CURDIR)/tb
export PROG_TB_DIR=$(CURDIR)/prog_tb
export DSN_DIR=$(CURDIR)/dsn
export SRC_DIR=$(DSN_DIR)/src
export INCLUDE_DIR=$(DSN_DIR)/include

export VERILATOR?=verilator
export GTKWAVE?=gtkwave

export VFLAGS?=--threads 16 -j 16
export VFLAGS+=--timing

include dsn/sources.mk

export HEADERS=$(shell find $(INCLUDE_DIR) -type f -name "*.svh")

TBS+=example
TBS+=decoder
TBS+=rob
TBS+=prf
TBS+=bus
TBS+=rename
TBS+=commit
TBS+=fu
TBS+=no_fetch
TBS+=top

.PHONY: all
all: $(foreach t, $(TBS), run-$t)

.PHONY: clean
clean: $(foreach t, $(TBS), clean-$t)
	cd $(PROG_TB_DIR) && $(MAKE) clean

.PHONY: prog-%
prog-%:
	cd $(PROG_TB_DIR) && PROG_NAME=$* $(MAKE) run

.PHONY: prog_wave-%
prog_wave-%:
	cd $(PROG_TB_DIR) && PROG_NAME=$* $(MAKE) wave

.PHONY: run-%
run-%:
	cd $(TB_DIR)/$* && $(MAKE) run

.PHONY: wave-%
wave-%:
	cd $(TB_DIR)/$* && $(MAKE) wave

.PHONY: clean-%
clean-%:
	cd $(TB_DIR)/$* && $(MAKE) clean
