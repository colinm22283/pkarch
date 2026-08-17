`ifndef RENAME_SVH
`define RENAME_SVH

`include "isa.svh"
`include "core/prf.svh"

typedef logic [$clog2(RENAME_CP_COUNT) - 1:0] rename_cp_id_t;

typedef struct packed {
    bit valid;

    bit write;

    reg_addr_t isa_addr;
} rename_dispatch_i_t;

typedef struct packed {
    bit ready;

    prf_addr_t prf_addr;
    prf_addr_t prev_addr;
} rename_dispatch_o_t;

typedef struct packed {
    bit valid;

    bit jmp;

    reg_addr_t isa_addr;
    prf_addr_t prev_addr;
} rename_commit_i_t;

typedef struct packed {
    bit ready;
} rename_commit_o_t;

typedef prf_addr_t rename_rat_t [REG_COUNT - 1:0];
typedef prf_addr_t rename_freelist_t [PRF_SIZE - 1:0];

`endif

