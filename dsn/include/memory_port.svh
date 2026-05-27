`ifndef MEMORY_PORT_SVH
`define MEMORY_PORT_SVH

`include "bus.svh"

typedef struct packed {
    bit req;

    bus_rw_t rw;
    bus_size_t size;

    bus_addr_t addr;
    bus_data_t data;
} memory_port_i_t;

typedef struct packed {
    bit ack;

    bus_data_t data;
} memory_port_o_t;

`endif

