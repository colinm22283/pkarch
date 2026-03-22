`ifndef FU_SVH
`define FU_SVH

`include "config.svh"
`include "prf.svh"
`include "defs.svh"
`include "isa.svh"
`include "rob.svh"

typedef struct packed {
    bit valid;

    dec_inst_t dec_inst;

    rob_id_t rob_id;

    prf_addr_t rs1, rs2, rd;
    word_t rs1_v, rs2_v;
} fu_dispatch_i_t;

typedef struct packed {
    bit ready;
} fu_dispatch_o_t;

typedef fu_dispatch_i_t [DISPATCH_WIDTH - 1:0] res_dispatch_i_t;
typedef fu_dispatch_o_t [DISPATCH_WIDTH - 1:0] res_dispatch_o_t;

`endif

