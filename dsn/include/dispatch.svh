`ifndef DISPATCH_SVH
`define DISPATCH_SVH

`include "isa.svh"
`include "rob.svh"

typedef struct packed {
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
