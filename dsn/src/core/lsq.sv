`timescale 1ns/100ps

`include "config.svh"
`include "isa.svh"
`include "core/lsq.svh"
`include "core/prf.svh"
`include "core/rob.svh"
`include "core/commit.svh"
`include "bus/bus.svh"
`include "test/logger.svh"

module lsq_m(
    input wire clk_i,
    input wire nrst_i,

    input wire flush_i,

    input  bus_miport_t [MEMORY_PORTS - 1:0] mports_i,
    output bus_moport_t [MEMORY_PORTS - 1:0] mports_o,

    input  lsq_dispatch_i_t [LSQ_DISPATCH_WIDTH - 1:0] lsq_dispatch_i,
    output lsq_dispatch_o_t [LSQ_DISPATCH_WIDTH - 1:0] lsq_dispatch_o,

    input  lsq_commit_i_t   lsq_commit_i,
    output lsq_commit_o_t   lsq_commit_o,

    input  commit_o_t [MEMORY_PORTS - 1:0] commit_i,
    output commit_i_t [MEMORY_PORTS - 1:0] commit_o,

    input  commit_o_t write_commit_i,
    output commit_i_t write_commit_o,

    input  wire  rob_write_valid_i,
    output logic rob_write_ready_o
);

    `DL_DEFINE(log, "lsq_m", `DL_YELLOW, `DL_ENABLE_LSQ);

endmodule

