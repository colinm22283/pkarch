`ifndef ICACHE_SVH
`define ICACHE_SVH

`include "bus/bus.svh"
`include "isa.svh"
`include "config.svh"

typedef struct packed {
    bit req;

    bus_addr_t addr;
} icache_i_t;

typedef struct packed {
    bit ack;

    inst_t [DISPATCH_WIDTH - 1:0] data;
} icache_o_t;

`endif
