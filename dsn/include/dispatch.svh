`ifndef DISPATCH_SVH
`define DISPATCH_SVH

`include "isa.svh"
`include "rob.svh"
`include "pc.svh"

typedef struct packed {
    bit valid;

    pc_t pc;

    dec_inst_t dec_inst;
} dispatch_i_t;

typedef struct packed {
    bit ready;
} dispatch_o_t;

typedef struct packed {
    bit valid;

    pc_t pc;

    dec_inst_t dec_inst;

    bit rob_id_valid;
    rob_id_t rob_id;

    bit rs1_valid;
    prf_addr_t rs1;

    bit rs2_valid;
    prf_addr_t rs2;

    bit rd_valid;
    prf_addr_t rd;
} dispatch_entry_t;

`endif
