`ifndef TYPES_SVH
`define TYPES_SVH

parameter ROB_ID_WIDTH = $clog2(ROB_SIZE);

typedef logic [ROB_ID_WIDTH - 1:0] rob_id_t;

`endif

