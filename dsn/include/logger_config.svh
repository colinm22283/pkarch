`ifndef LOGGER_CONFIG_SVH
`define LOGGER_CONFIG_SVH

`include "config.svh"

`define DL_ENABLE

// `define DL_RANDOM_COLORS

// bus
`define DL_ENABLE_SERIAL   1
`define DL_ENABLE_SIM_STOP 1
`define DL_ENABLE_ICACHE   `DEBUG_MODE

// fu
`define DL_ENABLE_MEM_FU `DEBUG_MODE

// core
`define DL_ENABLE_DISPATCH `DEBUG_MODE
`define DL_ENABLE_PRF      `DEBUG_MODE
`define DL_ENABLE_RENAME   `DEBUG_MODE
`define DL_ENABLE_FETCH    `DEBUG_MODE
`define DL_ENABLE_ROB      `DEBUG_MODE

`endif

