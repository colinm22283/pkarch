.PHONY: all
all: tb

.PHONY: clean
clean:
	cd hdl/tb && $(MAKE) clean

.PHONY: tb
tb:
	cd hdl/tb && $(MAKE) all

.PHONY: run-%
run-%:
	cd hdl/tb && $(MAKE) $@
	
.PHONY: wave-%
wave-%:
	cd hdl/tb && $(MAKE) $@

.PHONY: clean-%
clean-%:
	cd hdl/tb && $(MAKE) $@
 
