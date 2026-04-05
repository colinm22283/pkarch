`ifndef ROB_SVH
`define ROB_SVH

`include "isa.svh"
`include "prf.svh"
`include "pc.svh"

parameter ROB_ID_WIDTH = $clog2(ROB_SIZE);

typedef logic [ROB_ID_WIDTH - 1:0] rob_id_t;

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

    bit rd_a;
    reg_addr_t isa_addr;
    prf_addr_t prf_addr;
} rob_commit_i_t;

typedef struct packed {
    bit ready;
} rob_commit_o_t;

typedef struct packed {
    bit valid;
    bit busy;
    bit except;
    
    bit jmp;
    pc_t jmp_target;

    bit rd_a;
    reg_addr_t isa_rd;
    prf_addr_t prf_rd;
} rob_entry_t;

`endif

