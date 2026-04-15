`ifndef COMMIT_SVH
`define COMMIT_SVH

`include "rob.svh"

typedef struct packed {
    bit valid;

    rob_id_t rob_id;

    bit jmp;
    pc_t jmp_target;

    bit mem;
    word_t addr;

    reg_addr_t isa_addr;
    bit rd_a;
    prf_addr_t rd;
    prf_addr_t prev_rd;
    word_t value;
} commit_i_t;

typedef struct packed {
    bit ready;
} commit_o_t;

`endif

