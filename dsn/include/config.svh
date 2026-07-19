`ifndef CONFIG_SVH
`define CONFIG_SVH

`define DEBUG_MODE 0
`define SERIAL_ASCII_MODE 0

// CONFIGURABLE
parameter DISPATCH_WIDTH     = 1;
parameter RENAME_WIDTH       = 3;
parameter COMMIT_WIDTH       = 2;

parameter CHECKPOINT_COUNT   = 4;

parameter ISSUE_QUEUE_SIZE   = 2;

parameter ROB_SIZE           = 256;
parameter ROB_COMMIT_WIDTH   = 2;

parameter FU_COUNT           = 3;
parameter COMMIT_COUNT       = FU_COUNT + 1;

parameter PRF_SIZE           = 64;
parameter PRF_RPORTS         = 6;
parameter PRF_MEM_RPORTS     = 3;

parameter LSQ_SIZE           = 4;
parameter MEMORY_PORTS       = 1;
// CONFIGURABLE

parameter ROB_DISPATCH_WIDTH = DISPATCH_WIDTH;

parameter PRF_WPORTS         = ROB_COMMIT_WIDTH;

`endif

