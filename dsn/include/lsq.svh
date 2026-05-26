`ifndef LSQ_SVH
`define LSQ_SVH

`include "bus.svh"

typedef struct packed {
    bit valid;

    bus_rw_t rw;
    bus_size_t size;

    rob_id_t rob_id;

    word_t addr;
    union packed {
        struct packed {
            word_t value;
        } write;

        struct packed {
            reg_addr_t isa_addr;
            prf_addr_t rd;
            prf_addr_t prev_rd;

            bit [$bits(word_t) - $bits(reg_addr_t) - 2 * $bits(prf_addr_t) - 1:0] padding;
        } read;
    } data;
} lsq_dispatch_i_t;

typedef struct packed {
    bit ready;
} lsq_dispatch_o_t;

typedef struct packed {
    bus_rw_t rw;
    bus_size_t size;

    rob_id_t rob_id;

    word_t addr;
    union packed {
        struct packed {
            word_t value;
        } write;

        struct packed {
            reg_addr_t isa_addr;
            prf_addr_t rd;
            prf_addr_t prev_rd;

            bit [$bits(word_t) - $bits(reg_addr_t) - 2 * $bits(prf_addr_t) - 1:0] padding;
        } read;
    } data;
} lsq_entry_t;

`endif

