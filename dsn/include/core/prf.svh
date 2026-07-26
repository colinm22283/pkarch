`ifndef PRF_SVH
`define PRF_SVH

`include "config.svh"
`include "defs.svh"
`include "core/types.svh"

parameter PRF_ZERO_ADDR = PRF_SIZE;

parameter PRF_ADDR_WIDTH = $clog2(PRF_SIZE + 1);

typedef logic [PRF_ADDR_WIDTH - 1:0] prf_addr_t;

typedef struct packed {
    bit we;
    prf_addr_t addr;
    word_t data;
} prf_wport_i_t;

typedef struct packed {
    bit req;

    bit      port;
    rob_id_t rob_id;
    prf_addr_t addr;
} prf_rport_req_i_t;

typedef struct packed {
    bit ready;
} prf_rport_req_o_t;

typedef struct packed {
    bit ready;
} prf_rport_ack_i_t;

typedef struct packed {
    bit ack;

    bit      port;
    rob_id_t rob_id;
    word_t data;
} prf_rport_ack_o_t;

typedef struct packed {
    bit rel;

    prf_addr_t addr;
} prf_rel_i_t;

typedef struct packed {
    word_t data;
} prf_entry_t;

typedef struct packed {
    bit valid;

    bit      port;
    rob_id_t rob_id;
    prf_addr_t addr;
} prf_mem_rport_req_i_t;

typedef struct packed {
    bit ready;
} prf_mem_rport_req_o_t;

typedef prf_wport_i_t prf_mem_wport_i_t;
typedef prf_rel_i_t prf_mem_rel_i_t;

`endif

