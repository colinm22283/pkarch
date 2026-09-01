SRCS+=core/fetch.sv
SRCS+=core/fetch_expander.sv
SRCS+=core/inst_queue.sv
SRCS+=core/decoder.sv
SRCS+=core/dispatch.sv
SRCS+=core/rob.sv
SRCS+=core/prf.sv
SRCS+=core/prf_mem.sv
SRCS+=core/rename.sv
SRCS+=core/commit.sv
SRCS+=core/lsq.sv

SRCS+=fu/issue_queue.sv
SRCS+=fu/issue_req.sv
SRCS+=fu/issue_acc.sv
SRCS+=fu/execution_unit.sv
SRCS+=fu/fu_sel.sv

SRCS+=fu/alu.sv
SRCS+=fu/jmp.sv
SRCS+=fu/lsu.sv

SRCS+=bus/busarb.sv
SRCS+=bus/ram.sv
SRCS+=bus/serial.sv
SRCS+=bus/sim_stop.sv
SRCS+=bus/bus_master.sv
SRCS+=bus/mem_breakout.sv

SRCS+=bus/icache.sv
SRCS+=bus/icache_6_4_2.sv

SRCS+=test/clk_rst.v

SRCS+=state_log/state_logger.sv

SRCS+=pipe_reg.sv
SRCS+=fifo.sv

SRCS+=top.sv

export DSN_SRCS=$(foreach s, $(SRCS), $(SRC_DIR)/$s)

