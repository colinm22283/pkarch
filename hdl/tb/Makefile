TBS+=hello_world
TBS+=bus

.PHONY: all
all: $(foreach t, $(TBS), run-$t)

.PHONY: clean
clean: $(foreach t, $(TBS), clean-$t)

.PHONY: run-%
run-%:
	cd $* && $(MAKE) run

.PHONY: wave-%
wave-%:
	cd $* && $(MAKE) wave

.PHONY: clean-%
clean-%:
	cd $* && $(MAKE) clean

