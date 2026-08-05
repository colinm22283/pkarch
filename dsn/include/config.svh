`ifndef CONFIG_SVH
`define CONFIG_SVH

`define DEBUG_MODE 0
`define SERIAL_ASCII_MODE 1

// CONFIGURABLE
parameter DISPATCH_WIDTH     = 1;
parameter RENAME_WIDTH       = 3;
parameter COMMIT_WIDTH       = 2;

parameter CHECKPOINT_COUNT   = 4;

parameter ISSUE_QUEUE_SIZE   = 2;

parameter IQ_IN_SIZE         = 4;
parameter IQ_OUT_SIZE        = 4;
parameter IQ_ACC_SIZE        = 2;
parameter IQ_COMMIT_WIDTH    = 2;

parameter ROB_SIZE           = 256;
parameter ROB_COMMIT_WIDTH   = 2;

parameter ALU_COUNT = 1;
parameter JMP_COUNT = 1;

parameter PRF_SIZE           = 64;
parameter PRF_MEM_RPORTS     = DISPATCH_WIDTH;

parameter LSQ_SIZE           = 4;
parameter MEMORY_PORTS       = 1;
// CONFIGURABLE

parameter ROB_DISPATCH_WIDTH = DISPATCH_WIDTH;

parameter PRF_RPORTS         = 2 * DISPATCH_WIDTH;
parameter PRF_WPORTS         = ROB_COMMIT_WIDTH;

parameter IQ_OUT_WIDTH       = IQ_COMMIT_WIDTH * DISPATCH_WIDTH;

parameter FU_COUNT           = ALU_COUNT + JMP_COUNT;

parameter COMMIT_COUNT       = FU_COUNT + 2;

`endif

