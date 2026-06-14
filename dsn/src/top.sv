module top_m #(
    parameter MEMORY_PORTS = 1,
    parameter MEMORY_CROSSBARS = MEMORY_PORTS
) (
    input wire clk_i,
    input wire nrst_i,

    bus_siport_i [MEMORY_PORTS - 1:0] sports_i,
    bus_soport_o [MEMORY_PORTS - 1:0] sports_o
);

    busarb_m #(MEMORY_PORTS, 3, MEMORY_CROSSBARS) arbiter(
        .clk_i(clk),
        .nrst_i(nrst),

        .mports_i({ mportao, mportbo }),
        .mports_o({ mportai, mportbi }),

        .sports_i(sports_i),
        .sports_o(sports_o)
    );

    icache_m #(10, 5, 2) icache(
        .clk_i(clk),
        .nrst_i(nrst),

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

    prf_rport_i_t [PRF_RPORTS - 1:0] prf_rporti;
    prf_rport_o_t [PRF_RPORTS - 1:0] prf_rporto;

    prf_rel_i_t [COMMIT_WIDTH - 1:0] prf_reli;

    res_dispatch_i_t [FU_COUNT - 1:0] res_disi;
    res_dispatch_o_t [FU_COUNT - 1:0] res_diso;

    wire rob_write_ready, rob_write_valid;

    lsq_dispatch_i_t [1:0] lsq_disi;
    lsq_dispatch_o_t [1:0] lsq_diso;

    commit_i_t [FU_COUNT - 1:0] comi, reg_comi;
    commit_o_t [FU_COUNT - 1:0] como, reg_como;

    fetch_m fetch(
        .clk_i(clk),
        .nrst_i(nrst),

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
        .clk_i(clk),
        .nrst_i(nrst),

        .flush_i(flush),

        .sdispatch_i(dispatchi),
        .sdispatch_o(dispatcho),

        .mdispatch_i(expanded_dispatcho),
        .mdispatch_o(expanded_dispatchi)
    );
    
    issue_queue_m issue_queue(
        .clk_i(clk),
        .nrst_i(nrst),

        .flush_i(flush),

        .sdispatch_i(expanded_dispatchi),
        .sdispatch_o(expanded_dispatcho),

        .mdispatch_i(buffered_dispatcho),
        .mdispatch_o(buffered_dispatchi)
    );

    dispatch_m dispatch(
        .clk_i(clk),
        .nrst_i(nrst),

        .flush_i(flush),

        .rename_jump_o(rename_jump),
        .rename_jump_accept_i(rename_jump_accept),

        .dispatch_i(buffered_dispatchi),
        .dispatch_o(buffered_dispatcho),

        .rename_dispatch_i(rename_diso),
        .rename_dispatch_o(rename_disi),

        .rob_dispatch_i(rob_diso),
        .rob_dispatch_o(rob_disi),

        .res_dispatch_i(res_diso),
        .res_dispatch_o(res_disi)
    );

    rename_m rename(
        .clk_i(clk),
        .nrst_i(nrst),

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
        .clk_i(clk),
        .nrst_i(nrst),

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
        .clk_i(clk),
        .nrst_i(nrst),

        .prf_wport_i(prf_wporti),

        .prf_rport_i(prf_rporti),
        .prf_rport_o(prf_rporto),

        .prf_rel_i(prf_reli)
    );

    alu_m #(1, 16) alu(
        .clk_i(clk),
        .nrst_i(nrst),

        .flush_i(flush),

        .dispatch_i(res_disi[0]),
        .dispatch_o(res_diso[0]),

        .rport_i(prf_rporto[1:0]),
        .rport_o(prf_rporti[1:0]),

        .commit_i(como[0]),
        .commit_o(comi[0])
    );

    mem_m #(16) mem(
        .clk_i(clk),
        .nrst_i(nrst),

        .flush_i(flush),

        .dispatch_i(res_disi[1]),
        .dispatch_o(res_diso[1]),

        .rport_i(prf_rporto[3:2]),
        .rport_o(prf_rporti[3:2]),

        .lsq_dispatch_i(lsq_diso[0]),
        .lsq_dispatch_o(lsq_disi[0])
    );

    pipe_reg_m #(lsq_dispatch_i_t, lsq_dispatch_o_t) lsq_reg(
        .clk_i(clk),
        .nrst_i(nrst),

        .flush_i(flush),

        .s_i(lsq_disi[0]),
        .s_o(lsq_diso[0]),

        .m_i(lsq_diso[1]),
        .m_o(lsq_disi[1])
    );

    lsq_m lsq(
        .clk_i(clk),
        .nrst_i(nrst),

        .flush_i(flush),

        .mports_i(mportbi),
        .mports_o(mportbo),

        .dispatch_i(lsq_disi[1]),
        .dispatch_o(lsq_diso[1]),

        .commit_i(como[1]),
        .commit_o(comi[1]),

        .write_commit_i(como[2]),
        .write_commit_o(comi[2]),

        .rob_write_valid_i(rob_write_valid),
        .rob_write_ready_o(rob_write_ready)
    );

    jmp_m #(3) jmp(
        .clk_i(clk),
        .nrst_i(nrst),

        .flush_i(flush),

        .dispatch_i(res_disi[2]),
        .dispatch_o(res_diso[2]),

        .rport_i(prf_rporto[5:4]),
        .rport_o(prf_rporti[5:4]),

        .commit_i(como[3]),
        .commit_o(comi[3])
    );

    pipe_reg_m #(commit_i_t, commit_o_t) commit_pipe_reg [FU_COUNT - 1:0] (
        .clk_i(clk),
        .nrst_i(nrst),

        .flush_i(flush),

        .s_i(comi),
        .s_o(como),

        .m_i(reg_como),
        .m_o(reg_comi)
    );

    commit_m commit(
        .clk_i(clk),
        .nrst_i(nrst),

        .commit_i(reg_comi),
        .commit_o(reg_como),

        .rob_commit_i(rob_como),
        .rob_commit_o(rob_comi),

        .prf_wport_o(prf_wporti)
    );

endmodule

