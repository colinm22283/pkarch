`ifndef CONFIG_SVH
`define CONFIG_SVH

// CONFIGURABLE
parameter FETCH_WIDTH    = 1;
parameter DISPATCH_WIDTH = 1;
parameter RENAME_WIDTH   = 2;
parameter COMMIT_WIDTH   = 2;

parameter ROB_SIZE = 8;
parameter ROB_COMMIT_WIDTH = 1;

parameter FU_COUNT = 2;

parameter PRF_SIZE = 10;
parameter PRF_RPORTS = 3;
// CONFIGURABLE



parameter ROB_DISPATCH_WIDTH = DISPATCH_WIDTH;

parameter PRF_WPORTS = ROB_COMMIT_WIDTH;

`endif

