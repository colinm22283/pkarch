`ifndef RENAME_SVH
`define RENAME_SVH

`include "isa.svh"
`include "prf.svh"

typedef struct packed {
    bit valid;

    bit write;

    reg_addr_t isa_addr;
} rename_dispatch_i_t;

typedef struct packed {
    bit ready;

    prf_addr_t prf_addr;
} rename_dispatch_o_t;

typedef struct packed {
    bit valid;

    reg_addr_t isa_addr;
    prf_addr_t prf_addr;
} rename_commit_i_t;

typedef struct packed {
    bit ready;
} rename_commit_o_t;

typedef struct packed {
    bit valid;

    prf_addr_t prf_addr;
} rename_map_entry_t;

`endif

