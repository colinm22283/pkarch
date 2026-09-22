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
    input  logic clk_i,
    input  logic nrst_i,

    input  logic flush_i,

    input  bus_miport_t [LSQ_MEMORY_PORTS - 1:0] mports_i,
    output bus_moport_t [LSQ_MEMORY_PORTS - 1:0] mports_o,

    input  lsq_dispatch_i_t [LSQ_DISPATCH_WIDTH - 1:0] lsq_dispatch_i,
    output lsq_dispatch_o_t [LSQ_DISPATCH_WIDTH - 1:0] lsq_dispatch_o,

    input  lsq_commit_i_t [LSU_COUNT - 1:0] lsq_commit_i,
    output lsq_commit_o_t [LSU_COUNT - 1:0] lsq_commit_o,

    input  commit_o_t commit_i,
    output commit_i_t commit_o,

    input  commit_o_t write_commit_i,
    output commit_i_t write_commit_o,

    input  logic rob_write_valid_i,
    output logic rob_write_ready_o
);

    `DL_DEFINE(log, "lsq_m", `DL_YELLOW, `DL_ENABLE_LSQ);

    lsq_dispatch_i_t [LSQ_DISPATCH_WIDTH - 1:0] lsq_dispatchi;
    lsq_dispatch_o_t [LSQ_DISPATCH_WIDTH - 1:0] lsq_dispatcho;

    lsq_commit_o_t [LSU_COUNT - 1:0] write_lsq_commito;
    lsq_commit_o_t [LSU_COUNT - 1:0] read_lsq_commito;

    logic read_ready, read_valid;
    rob_id_t read_rob_id;

    logic write_ready, write_valid;
    rob_id_t write_rob_id;

    logic      store_ready, store_valid;
    bus_size_t store_size;
    word_t     store_addr;
    word_t     store_value;

    generate for (genvar i = 0; i < LSQ_DISPATCH_WIDTH; i++) begin
        pipe_reg_lsq_m dispatch_pipe_reg(
            .clk_i(clk_i),
            .nrst_i(nrst_i),

            .flush_i(flush_i),

            .s_i(lsq_dispatch_i[i]),
            .s_o(lsq_dispatch_o[i]),

            .m_i(lsq_dispatcho[i]),
            .m_o(lsq_dispatchi[i])
        );
    end endgenerate

    lsq_dispatch_demux_m dispatch_demux(
        .lsq_dispatch_i(lsq_dispatchi),
        .lsq_dispatch_o(lsq_dispatcho),

        .read_ready_i(read_ready),
        .read_valid_o(read_valid),
        .read_rob_id_o(read_rob_id),

        .write_ready_i(write_ready),
        .write_valid_o(write_valid),
        .write_rob_id_o(write_rob_id)
    );

    lsq_write_queue_m write_queue(
        .clk_i(clk_i),
        .nrst_i(nrst_i),
        
        .flush_i(flush_i),

        .valid_i(write_valid),
        .ready_o(write_ready),
        .rob_id_i(write_rob_id),

        .commit_i(lsq_commit_i),
        .commit_o(write_lsq_commito),

        .write_commit_i(write_commit_i),
        .write_commit_o(write_commit_o),

        .rob_write_valid_i(rob_write_valid_i),
        .rob_write_ready_o(rob_write_ready_o),

        .store_valid_o(store_valid),
        .store_ready_i(store_ready),
        .size_o(store_size),
        .addr_o(store_addr),
        .value_o(store_value)
    );

    generate if (LSQ_MEMORY_PORTS == 2) begin
        lsq_store_memory_sm_m store_memory_sm(
            .clk_i(clk_i),
            .nrst_i(nrst_i),

            .mport_i(mports_i[1]),
            .mport_o(mports_o[1]),

            .valid_i(store_valid),
            .ready_o(store_ready),
            .size_i(store_size),
            .addr_i(store_addr),
            .value_i(store_value)
        );

        assign mports_o[0] = '0;
    end
    else if (LSQ_MEMORY_PORTS == 1) begin
        // TODO
    end endgenerate

    always_comb for (int i = 0; i < LSU_COUNT; i++) begin
        lsq_commit_o[i].ready = write_lsq_commito[i].ready || read_lsq_commito[i].ready;
    end

endmodule

