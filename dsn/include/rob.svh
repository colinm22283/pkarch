`ifndef ROB_SVH
`define ROB_SVH

`include "isa.svh"

typedef logic [$clog2(ROB_SIZE) - 1:0] rob_id_t;

typedef struct packed {
    bit valid;
} rob_dispatch_i_t;

typedef struct packed {
    bit ready;

    rob_id_t id;
} rob_dispatch_o_t;

typedef struct packed {
    bit valid;
    bit busy;
    bit except;
} rob_entry_t;

`endif

