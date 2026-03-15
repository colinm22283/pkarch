SRCS+=core/decoder.sv
SRCS+=core/rob.sv
SRCS+=core/prf.sv

SRCS+=test/clk_rst.v

export DSN_SRCS=$(foreach s, $(SRCS), $(SRC_DIR)/$s)

