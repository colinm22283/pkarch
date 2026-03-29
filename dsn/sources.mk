SRCS+=core/decoder.sv
SRCS+=core/dispatch.sv
SRCS+=core/rob.sv
SRCS+=core/prf.sv
SRCS+=core/rename.sv
SRCS+=core/commit.sv

SRCS+=fu/res_station.sv

SRCS+=fu/alu/fu.sv
SRCS+=fu/alu/test.sv
SRCS+=fu/alu/alu.sv

SRCS+=bus/busarb.sv
SRCS+=bus/ram.sv
SRCS+=bus/bus_master.sv

SRCS+=test/clk_rst.v

SRCS+=pipe_reg.sv

export DSN_SRCS=$(foreach s, $(SRCS), $(SRC_DIR)/$s)

