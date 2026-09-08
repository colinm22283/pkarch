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

    input  bus_miport_t [WRITE_PORTS - 1:0] read_mports_i,
    output bus_moport_t [WRITE_PORTS - 1:0] read_mports_o,

    input  bus_miport_t [WRITE_PORTS - 1:0] write_mports_i,
    output bus_moport_t [WRITE_PORTS - 1:0] write_mports_o,

    input  lsq_dispatch_i_t dispatch_i,
    output lsq_dispatch_o_t dispatch_o,

    input  commit_o_t [MEMORY_PORTS - 1:0] commit_i,
    output commit_i_t [MEMORY_PORTS - 1:0] commit_o,

    input  commit_o_t write_commit_i,
    output commit_i_t write_commit_o,

    input  wire  rob_write_valid_i,
    output logic rob_write_ready_o
);

    `DL_DEFINE(log, "lsq_m", `DL_YELLOW, `DL_ENABLE_LSQ);

endmodule

