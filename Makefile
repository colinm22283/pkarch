export TB_DIR=$(CURDIR)/tb
export DSN_DIR=$(CURDIR)/dsn
export SRC_DIR=$(DSN_DIR)/src
export INCLUDE_DIR=$(DSN_DIR)/include

export VERILATOR?=verilator
export GTKWAVE?=gtkwave

export VFLAGS?=--threads 16 -j 16
export VFLAGS+=--timing

include dsn/sources.mk

TBS+=example
TBS+=decoder

.PHONY: all
all: $(foreach t, $(TBS), run-$t)

.PHONY: clean
clean: $(foreach t, $(TBS), clean-$t)

.PHONY: run-%
run-%:
	cd $(TB_DIR)/$* && $(MAKE) run

.PHONY: wave-%
wave-%:
	cd $(TB_DIR)/$* && $(MAKE) wave

.PHONY: clean-%
clean-%:
	cd $(TB_DIR)/$* && $(MAKE) clean
