`ifndef ROB_SVH
`define ROB_SVH

`include "config.svh"
`include "isa.svh"
`include "core/prf.svh"
`include "core/types.svh"
`include "core/pc.svh"

typedef struct packed {
    bit valid;
} rob_dispatch_i_t;

typedef struct packed {
    bit ready;

    rob_id_t id;
} rob_dispatch_o_t;

typedef struct packed {
    bit valid;

    rob_id_t rob_id;

    bit jmp;
    bit mispred;
    pc_t jmp_target;

    bit mem;

    bit rd_a;
    reg_addr_t isa_addr;
    prf_addr_t prev_addr;
} rob_commit_i_t;

typedef struct packed {
    bit ready;
} rob_commit_o_t;

typedef struct packed {
    bit valid;
    bit busy;
    bit except;
    
    bit jmp;
    bit mispred;
    pc_t jmp_target;

    bit mem;

    bit rd_a;
    reg_addr_t isa_rd;
    prf_addr_t prev_rd;
} rob_entry_t;

`endif

