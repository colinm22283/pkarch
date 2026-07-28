`timescale 1ns/100ps

`include "isa.svh"
`include "core/fetch.svh"
`include "core/rob.svh"
`include "core/rename.svh"
`include "core/dispatch.svh"
`include "core/lsq.svh"
`include "core/commit.svh"
`include "bus/bus.svh"
`include "bus/icache.svh"

module top_m #(
    parameter MEMORY_PORTS = 1,
    parameter MEMORY_CROSSBARS = MEMORY_PORTS
) (
`ifdef USE_POWER_PINS
    inout wire vccd1,
    inout wire vssd1,
`endif

    input wire clk_i,
    input wire nrst_i,

    input  bus_miport_t [MEMORY_PORTS - 1:0] mports_i,
    output bus_moport_t [MEMORY_PORTS - 1:0] mports_o
);

    bus_miport_t mportai;
    bus_moport_t mportao;

    bus_miport_t mportbi;
    bus_moport_t mportbo;

    icache_i_t icachei;
    icache_o_t icacheo;

    busarb_m #(2, MEMORY_PORTS, MEMORY_CROSSBARS) arbiter(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .mports_i({ mportao, mportbo }),
        .mports_o({ mportai, mportbi }),

        .sports_i(mports_i),
        .sports_o(mports_o)
    );

    icache_6_4_2_m icache(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .icache_i(icachei),
        .icache_o(icacheo),

        .mport_i(mportai),
        .mport_o(mportao)
    );

    fetch_jump_i_t jumpi;
    fetch_jump_o_t jumpo;

    logic flush;
    logic rename_flush_complete;
    
    dispatch_i_t dispatchi;
    dispatch_o_t dispatcho;

    dispatch_i_t [DISPATCH_WIDTH - 1:0] expanded_dispatchi;
    dispatch_o_t [DISPATCH_WIDTH - 1:0] expanded_dispatcho;
    
    dispatch_i_t [DISPATCH_WIDTH - 1:0] buffered_dispatchi;
    dispatch_o_t [DISPATCH_WIDTH - 1:0] buffered_dispatcho;

    rename_dispatch_i_t [RENAME_WIDTH - 1:0] rename_disi;
    rename_dispatch_o_t [RENAME_WIDTH - 1:0] rename_diso;

    wire rename_jump, rename_jump_accept;
    wire rename_jump_commit;

    rename_commit_i_t [COMMIT_WIDTH - 1:0] rename_comi;
    rename_commit_o_t [COMMIT_WIDTH - 1:0] rename_como;

    rob_dispatch_i_t [ROB_DISPATCH_WIDTH - 1:0] rob_disi;
    rob_dispatch_o_t [ROB_DISPATCH_WIDTH - 1:0] rob_diso;

    rob_commit_i_t [ROB_COMMIT_WIDTH - 1:0] rob_comi;
    rob_commit_o_t [ROB_COMMIT_WIDTH - 1:0] rob_como;

    prf_wport_i_t [PRF_WPORTS - 1:0] prf_wporti;

    prf_rport_req_i_t [PRF_RPORTS - 1:0] prf_rport_reqi;
    prf_rport_req_o_t [PRF_RPORTS - 1:0] prf_rport_reqo;
    prf_rport_ack_i_t [PRF_MEM_RPORTS - 1:0] prf_rport_acki;
    prf_rport_ack_o_t [PRF_MEM_RPORTS - 1:0] prf_rport_acko;

    prf_rel_i_t [COMMIT_WIDTH - 1:0] prf_reli;

    iq_dispatch_i_t [DISPATCH_WIDTH - 1:0] iq_disi;
    iq_dispatch_o_t [DISPATCH_WIDTH - 1:0] iq_diso;

    iq_commit_i_t [IQ_OUT_WIDTH - 1:0] iq_comi;
    iq_commit_o_t [IQ_OUT_WIDTH - 1:0] iq_como;

    wire rob_write_ready, rob_write_valid;

    lsq_dispatch_i_t [1:0] lsq_disi;
    lsq_dispatch_o_t [1:0] lsq_diso;

    commit_i_t [COMMIT_COUNT - 1:0] comi, reg_comi;
    commit_o_t [COMMIT_COUNT - 1:0] como, reg_como;

    fetch_m fetch(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .icache_i(icacheo),
        .icache_o(icachei),

        .jump_i(jumpi),
        .jump_o(jumpo),

        .flush_o(flush),
        .flush_complete_i(rename_flush_complete),

        .dispatch_i(dispatcho),
        .dispatch_o(dispatchi)
    );

    fetch_expander_m fetch_expander(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .flush_i(flush),

        .sdispatch_i(dispatchi),
        .sdispatch_o(dispatcho),

        .mdispatch_i(expanded_dispatcho),
        .mdispatch_o(expanded_dispatchi)
    );
    
    inst_queue_m inst_queue(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .flush_i(flush),

        .sdispatch_i(expanded_dispatchi),
        .sdispatch_o(expanded_dispatcho),

        .mdispatch_i(buffered_dispatcho),
        .mdispatch_o(buffered_dispatchi)
    );

    dispatch_m dispatch(
`ifdef USE_POWER_PINS
        .vccd1(vccd1),
        .vssd1(vssd1),
`endif
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .flush_i(flush),

        .rename_jump_o(rename_jump),
        .rename_jump_accept_i(rename_jump_accept),

        .dispatch_i(buffered_dispatchi),
        .dispatch_o(buffered_dispatcho),

        .rename_dispatch_i(rename_diso),
        .rename_dispatch_o(rename_disi),

        .rob_dispatch_i(rob_diso),
        .rob_dispatch_o(rob_disi),

        .iq_dispatch_i(iq_diso),
        .iq_dispatch_o(iq_disi)
    );

    rename_m rename(
`ifdef USE_POWER_PINS
        .vccd1(vccd1),
        .vssd1(vssd1),
`endif
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .flush_i(flush),
        .flush_complete_o(rename_flush_complete),

        .jump_i(rename_jump),
        .jump_accept_o(rename_jump_accept),
        .jump_commit_i(rename_jump_commit),

        .dispatch_i(rename_disi),
        .dispatch_o(rename_diso),

        .commit_i(rename_comi),
        .commit_o(rename_como),

        .prf_rel_o(prf_reli)
    );

    rob_m rob(
`ifdef USE_POWER_PINS
        .vccd1(vccd1),
        .vssd1(vssd1),
`endif
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .flush_i(flush),

        .rename_jump_commit_o(rename_jump_commit),

        .dispatch_i(rob_disi),
        .dispatch_o(rob_diso),

        .commit_i(rob_comi),
        .commit_o(rob_como),

        .rename_commit_i(rename_como),
        .rename_commit_o(rename_comi),

        .jump_i(jumpo),
        .jump_o(jumpi),

        .rob_write_ready_i(rob_write_ready),
        .rob_write_valid_o(rob_write_valid)
    );

    prf_m prf(
`ifdef USE_POWER_PINS
        .vccd1(vccd1),
        .vssd1(vssd1),
`endif
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .flush_i(flush),
        .jump_i(rename_jump),
        .jump_commit_i(rename_jump_commit),

        .prf_wport_i(prf_wporti),

        .prf_rport_req_i(prf_rport_reqi),
        .prf_rport_req_o(prf_rport_reqo),
        .prf_rport_ack_i(prf_rport_acki),
        .prf_rport_ack_o(prf_rport_acko),

        .prf_rel_i(prf_reli)
    );

    issue_queue_m issue_queue(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .flush_i(flush),

        .dispatch_i(iq_disi),
        .dispatch_o(iq_diso),
        
        .commit_i(iq_comi),
        .commit_o(iq_como),

        .rports_req_i(prf_rport_reqo),
        .rports_req_o(prf_rport_reqi),
        .rports_ack_i(prf_rport_acko),
        .rports_ack_o(prf_rport_acki)
    );

    execution_unit_m execution_unit(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .flush_i(flush),

        .dispatch_i(iq_como),
        .dispatch_o(iq_comi),
        
        .commit_i(como[FU_COUNT - 1:0]),
        .commit_o(comi[FU_COUNT - 1:0]),

        .lsq_dispatch_i(lsq_diso[0]),
        .lsq_dispatch_o(lsq_disi[0])
    );

    pipe_reg_lsq_m lsq_reg(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .flush_i(flush),

        .s_i(lsq_disi[0]),
        .s_o(lsq_diso[0]),

        .m_i(lsq_diso[1]),
        .m_o(lsq_disi[1])
    );

    // assign lsq_disi[1] = lsq_disi[0];
    // assign lsq_diso[0] = lsq_diso[1];

    lsq_m lsq(
`ifdef USE_POWER_PINS
        .vccd1(vccd1),
        .vssd1(vssd1),
`endif
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .flush_i(flush),

        .mports_i(mportbi),
        .mports_o(mportbo),

        .dispatch_i(lsq_disi[1]),
        .dispatch_o(lsq_diso[1]),

        .commit_i(como[FU_COUNT]),
        .commit_o(comi[FU_COUNT]),

        .write_commit_i(como[FU_COUNT + 1]),
        .write_commit_o(comi[FU_COUNT + 1]),

        .rob_write_valid_i(rob_write_valid),
        .rob_write_ready_o(rob_write_ready)
    );

    generate
        for (genvar i = 0; i < COMMIT_COUNT; i++) begin
            pipe_reg_commit_m commit_pipe_reg (
                .clk_i(clk_i),
                .nrst_i(nrst_i),

                .flush_i(flush),

                .s_i(comi[i]),
                .s_o(como[i]),

                .m_i(reg_como[i]),
                .m_o(reg_comi[i])
            );
        end
    endgenerate

    // generate
        // for (genvar i = 0; i < FU_COUNT; i++) begin
            // assign reg_comi[i] = comi[i];
            // assign como[i] = reg_como[i];
        // end
    // endgenerate

    commit_m commit(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .commit_i(reg_comi),
        .commit_o(reg_como),

        .rob_commit_i(rob_como),
        .rob_commit_o(rob_comi),

        .prf_wport_o(prf_wporti)
    );

endmodule

