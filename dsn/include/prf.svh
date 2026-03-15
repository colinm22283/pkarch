`ifndef PRF_SVH
`define PRF_SVH

`include "config.svh"
`include "defs.svh"

parameter PRF_ADDR_WIDTH = $clog2(PRF_SIZE);

typedef logic [PRF_ADDR_WIDTH - 1:0] prf_addr_t;

typedef struct packed {
    prf_addr_t addr;
    word_t data;
    bit we;
} prf_port_i_t;

typedef struct packed {
    word_t data;
} prf_port_o_t;

`endif

