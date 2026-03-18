SRCS+=core/decoder.sv
SRCS+=core/rob.sv
SRCS+=core/prf.sv
SRCS+=core/rename.sv
SRCS+=core/commit.sv

SRCS+=fu/alu.sv

SRCS+=bus/busarb.sv
SRCS+=bus/ram.sv
SRCS+=bus/bus_master.sv

SRCS+=test/clk_rst.v

SRCS+=pipe_reg.sv

export DSN_SRCS=$(foreach s, $(SRCS), $(SRC_DIR)/$s)

