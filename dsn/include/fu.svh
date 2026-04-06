`ifndef FU_SVH
`define FU_SVH

`include "config.svh"
`include "prf.svh"
`include "defs.svh"
`include "isa.svh"
`include "rob.svh"
`include "pc.svh"

typedef struct packed {
    bit valid;

    pc_t pc;

    dec_inst_t dec_inst;

    rob_id_t rob_id;

    prf_addr_t rs1, rs2, rd;
    reg_addr_t isa_addr;
} fu_dispatch_i_t;

typedef struct packed {
    bit ready;
} fu_dispatch_o_t;

typedef struct packed {
    dec_inst_t dec_inst;
} [DISPATCH_WIDTH - 1:0] fu_test_i_t;

typedef struct packed {
    bit accept;
} [DISPATCH_WIDTH - 1:0] fu_test_o_t;

typedef fu_dispatch_i_t [DISPATCH_WIDTH - 1:0] res_dispatch_i_t;
typedef fu_dispatch_o_t [DISPATCH_WIDTH - 1:0] res_dispatch_o_t;

typedef struct packed {
    pc_t pc;

    dec_inst_t dec_inst;

    rob_id_t rob_id;

    prf_addr_t rs1, rs2, rd;
    reg_addr_t isa_addr;
} res_station_entry_t;

`endif

