`ifndef CONFIG_SVH
`define CONFIG_SVH

`define DEBUG_MODE 1

// CONFIGURABLE
parameter DISPATCH_WIDTH = 1;
parameter RENAME_WIDTH   = 3;
parameter COMMIT_WIDTH   = 2;

parameter ISSUE_QUEUE_SIZE = 8;

parameter ROB_SIZE = 64;
parameter ROB_COMMIT_WIDTH = 1;

parameter FU_COUNT = 3;

parameter PRF_SIZE = 64;
parameter PRF_RPORTS = 6;

parameter MEMORY_PORTS = 2;
// CONFIGURABLE

parameter ROB_DISPATCH_WIDTH = DISPATCH_WIDTH;

parameter PRF_WPORTS = ROB_COMMIT_WIDTH;

`endif

