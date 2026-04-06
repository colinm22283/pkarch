`ifndef FETCH_SVH
`define FETCH_SVH

typedef struct packed {
    bit valid;

    pc_t target;
} fetch_jump_i_t;

typedef struct packed {
    bit ready;
} fetch_jump_o_t;

`endif
