SRCS+=core/fetch.sv
SRCS+=core/fetch_expander.sv
SRCS+=core/issue_queue.sv
SRCS+=core/decoder.sv
SRCS+=core/dispatch.sv
SRCS+=core/rob.sv
SRCS+=core/prf.sv
SRCS+=core/prf_mem.sv
SRCS+=core/rename.sv
SRCS+=core/commit.sv
SRCS+=core/lsq.sv

SRCS+=fu/res_station.sv
SRCS+=fu/prf_req.sv

SRCS+=fu/alu/fu.sv
SRCS+=fu/alu/test.sv
SRCS+=fu/alu/alu.sv

SRCS+=fu/mem/fu.sv
SRCS+=fu/mem/test.sv
SRCS+=fu/mem/mem.sv

SRCS+=fu/jmp/fu.sv
SRCS+=fu/jmp/test.sv
SRCS+=fu/jmp/jmp.sv

SRCS+=bus/busarb.sv
SRCS+=bus/ram.sv
SRCS+=bus/serial.sv
SRCS+=bus/sim_stop.sv
SRCS+=bus/bus_master.sv
SRCS+=bus/mem_breakout.sv

SRCS+=bus/icache.sv
SRCS+=bus/icache_6_4_2.sv

SRCS+=test/clk_rst.v

SRCS+=pipe_reg.sv

SRCS+=top.sv

export DSN_SRCS=$(foreach s, $(SRCS), $(SRC_DIR)/$s)

