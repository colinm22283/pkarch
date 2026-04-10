`ifndef ICACHE_SVH
`define ICACHE_SVH

`include "bus.svh"

typedef struct packed {
    bit req;

    bus_addr_t addr;
} icache_i_t;

typedef struct packed {
    bit ack;

    bus_data_t data;
} icache_o_t;

`endif
