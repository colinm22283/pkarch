`ifndef PRF_SVH
`define PRF_SVH

`include "config.svh"
`include "defs.svh"

parameter PRF_ZERO_ADDR = PRF_SIZE;

parameter PRF_ADDR_WIDTH = $clog2(PRF_SIZE + 1);

typedef logic [PRF_ADDR_WIDTH - 1:0] prf_addr_t;

typedef struct packed {
    bit we;
    prf_addr_t addr;
    word_t data;
} prf_wport_i_t;

typedef struct packed {
    prf_addr_t addr;
} prf_rport_i_t;

typedef struct packed {
    bit valid;

    word_t data;
} prf_rport_o_t;

typedef struct packed {
    bit rel;

    prf_addr_t addr;
} prf_rel_i_t;

typedef struct packed {
    bit claim;

    prf_addr_t addr;
} prf_claim_i_t;

typedef struct packed {
    bit valid;

    word_t data;
} prf_entry_t;

`endif

