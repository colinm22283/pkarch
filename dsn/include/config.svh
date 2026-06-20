`ifndef CONFIG_SVH
`define CONFIG_SVH

`define DEBUG_MODE 0
`define SERIAL_ASCII_MODE 0

// CONFIGURABLE
parameter DISPATCH_WIDTH         = 1;
parameter RENAME_WIDTH           = 3;
parameter COMMIT_WIDTH           = 2;

parameter RENAME_CHECKPOINT_SIZE = 4;

parameter ISSUE_QUEUE_SIZE       = 8;

parameter ROB_SIZE               = 64;
parameter ROB_COMMIT_WIDTH       = 2;

parameter FU_COUNT               = 3 + 1;

parameter PRF_SIZE               = 64;
parameter PRF_RPORTS             = 6;

parameter LSQ_SIZE               = 8;
parameter MEMORY_PORTS           = 1;
// CONFIGURABLE

parameter ROB_DISPATCH_WIDTH     = DISPATCH_WIDTH;

parameter PRF_WPORTS             = ROB_COMMIT_WIDTH;

`endif

