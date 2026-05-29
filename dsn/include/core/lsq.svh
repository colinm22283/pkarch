`ifndef LSQ_SVH
`define LSQ_SVH

`include "defs.svh"
`include "bus/bus.svh"

typedef struct packed {
    bit valid;

    bus_size_t size;
    bus_rw_t   rw;
    word_t     addr;
} lsq_dispatch_i_t;

typedef struct packed {
    bit ready;
} lsq_dispatch_o_t;

typedef struct packed {
    bus_size_t size;
    bus_rw_t   rw;
    word_t     addr;
} lsq_entry_t;

`endif

