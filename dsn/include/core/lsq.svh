`ifndef LSQ_SVH
`define LSQ_SVH

`include "defs.svh"
`include "isa.svh"
`include "core/prf.svh"
`include "core/rob.svh"
`include "bus/bus.svh"

parameter LSQ_DATA_SIZE = `MAX($bits(reg_addr_t) + 2 * $bits(prf_addr_t), $bits(word_t));

typedef union packed {
    struct packed {
        reg_addr_t isa_addr;
        prf_addr_t rd;
        prf_addr_t prev_rd;

        logic [LSQ_DATA_SIZE - ($bits(reg_addr_t) + 2 * $bits(prf_addr_t)) - 1:0] _padding;
    } read;

    struct packed {
        word_t value;
    } write;
} lsq_data_t;

typedef struct packed {
    bit valid;

    rob_id_t rob_id;

    bus_size_t size;
    bus_rw_t   rw;
    word_t     addr;

    lsq_data_t data;
} lsq_dispatch_i_t;

typedef struct packed {
    bit ready;
} lsq_dispatch_o_t;

typedef struct packed {
    rob_id_t rob_id;

    bus_size_t size;
    bus_rw_t   rw;
    word_t     addr;

    lsq_data_t data;
} lsq_entry_t;

`endif

