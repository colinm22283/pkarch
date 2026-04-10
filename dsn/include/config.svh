`ifndef CONFIG_SVH
`define CONFIG_SVH

// CONFIGURABLE
parameter DISPATCH_WIDTH = 1;
parameter RENAME_WIDTH   = 1;
parameter COMMIT_WIDTH   = 1;

parameter ISSUE_QUEUE_SIZE = 8;

parameter ROB_SIZE = 8;
parameter ROB_COMMIT_WIDTH = 1;

parameter FU_COUNT = 3;

parameter PRF_SIZE = 10;
parameter PRF_RPORTS = 6;
// CONFIGURABLE



parameter ROB_DISPATCH_WIDTH = DISPATCH_WIDTH;

parameter PRF_WPORTS = ROB_COMMIT_WIDTH;

`endif

