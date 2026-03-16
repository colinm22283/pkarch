`ifndef CONFIG_SVH
`define CONFIG_SVH

parameter FETCH_WIDTH = 2;
parameter RENAME_WIDTH = 2;
parameter COMMIT_WIDTH = 2;

parameter FU_COUNT = 1;

parameter ROB_DISPATCH_WIDTH = 2;
parameter ROB_COMMIT_WIDTH = 2;
parameter ROB_SIZE = 8;

parameter PRF_SIZE = 64;
parameter PRF_WPORTS = ROB_COMMIT_WIDTH;

`endif

