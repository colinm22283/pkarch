`ifndef CONFIG_SVH
`define CONFIG_SVH

parameter FETCH_WIDTH = 1;
parameter RENAME_WIDTH = 1;
parameter COMMIT_WIDTH = 1;
parameter DISPATCH_WIDTH = 1;

parameter FU_COUNT = 1;

parameter ROB_DISPATCH_WIDTH = 1;
parameter ROB_COMMIT_WIDTH = 1;
parameter ROB_SIZE = 8;

parameter PRF_SIZE = 64;
parameter PRF_WPORTS = ROB_COMMIT_WIDTH;
parameter PRF_RPORTS = 2;

`endif

