SRCS=core/decoder.v

SRCS=test/clk_rst.v

export DSN_SRCS=$(foreach s, $(SRCS), $(SRC_DIR)/$s)

