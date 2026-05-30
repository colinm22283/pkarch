`ifndef DEFS_SVH
`define DEFS_SVH

parameter WORD_WIDTH = 32;

typedef logic [WORD_WIDTH - 1:0] word_t;
typedef logic signed [WORD_WIDTH - 1:0] sword_t;

`define MAX(a, b) ((a) > (b) ? (a) : (b))
`define MIN(a, b) ((a) < (b) ? (a) : (b))

`endif

