`ifndef PC_SVH
`define PC_SVH

`include "bus.svh"

parameter PC_WIDTH = BUS_ADDR_WIDTH;

typedef logic [PC_WIDTH - 1:0] pc_t;

`endif
