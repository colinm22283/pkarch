`ifndef ISSUE_QUEUE_SVH
`define ISSUE_QUEUE_SVH

typedef struct packed {
    pc_t pc;

    dec_inst_t dec_inst;

    rob_id_t rob_id;

    prf_addr_t rs1, rs2, rd, prev_rd;
    reg_addr_t isa_addr;
} iq_in_data_t;

typedef struct packed {
    rob_id_t rob_id;

    word_t rs1_v, rs2_v;

    prf_addr_t rd, prev_rd;
    reg_addr_t isa_addr;
} iq_out_data_t;

typedef struct packed {
    bit valid;

    iq_in_data_t data;
} iq_dispatch_i_t;

typedef struct packed {
    bit ready;
} iq_dispatch_o_t;

typedef struct packed {
    bit valid;

    iq_out_data_t data;
} iq_commit_i_t;

typedef struct packed {
    bit ready;
} iq_commit_o_t;

`endif
