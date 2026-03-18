`ifndef COMMIT_SVH
`define COMMIT_SVH

`include "rob.svh"

typedef struct packed {
    bit valid;

    rob_id_t rob_id;

    reg_addr_t isa_addr;
    prf_addr_t rd;
    word_t value;
} commit_i_t;

typedef struct packed {
    bit ready;
} commit_o_t;

`endif

