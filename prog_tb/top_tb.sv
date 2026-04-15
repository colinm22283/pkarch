`timescale 1ns/100ps

`include "isa.svh"
`include "icache.svh"

module top_tb();

    wire clk, nrst;

    clk_rst_m clk_rst(
        .clk_o(clk),
        .nrst_o(nrst)
    );

    bus_miport_t mportai;
    bus_moport_t mportao;

    bus_miport_t [MEMORY_PORTS - 1:0] rob_mportsi;
    bus_moport_t [MEMORY_PORTS - 1:0] rob_mportso;

    bus_siport_t sportai;
    bus_soport_t sportao;

    bus_siport_t sportbi;
    bus_soport_t sportbo;

    bus_siport_t sportci;
    bus_soport_t sportco;

    icache_i_t icachei;
    icache_o_t icacheo;

    busarb_m #(MEMORY_PORTS + 1, 3, 2) arbiter(
        .clk_i(clk),
        .nrst_i(nrst),

        .mports_i({ mportao, rob_mportso }),
        .mports_o({ mportai, rob_mportsi }),

        .sports_i({ sportao, sportbo, sportco }),
        .sports_o({ sportai, sportbi, sportci })
    );

    ram_m #(0, 1024) ram(
        .clk_i(clk),
        .nrst_i(nrst),

        .sport_i(sportai),
        .sport_o(sportao)
    );

    serial_m #(1024) serial(
        .clk_i(clk),
        .nrst_i(nrst),

        .sport_i(sportbi),
        .sport_o(sportbo)
    );

    sim_stop_m #(1025) sim_stop(
        .clk_i(clk),
        .nrst_i(nrst),
        
        .sport_i(sportci),
        .sport_o(sportco)
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
    
    dispatch_i_t [DISPATCH_WIDTH - 1:0] dispatchi;
    dispatch_o_t [DISPATCH_WIDTH - 1:0] dispatcho;
    
    dispatch_i_t [DISPATCH_WIDTH - 1:0] buffered_dispatchi;
    dispatch_o_t [DISPATCH_WIDTH - 1:0] buffered_dispatcho;

    rename_dispatch_i_t [RENAME_WIDTH - 1:0] rename_disi;
    rename_dispatch_o_t [RENAME_WIDTH - 1:0] rename_diso;

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
    
    issue_queue_m issue_queue(
        .clk_i(clk),
        .nrst_i(nrst),

        .sdispatch_i(dispatchi),
        .sdispatch_o(dispatcho),

        .mdispatch_i(buffered_dispatcho),
        .mdispatch_o(buffered_dispatchi)
    );

    dispatch_m dispatch(
        .clk_i(clk),
        .nrst_i(nrst),

        .flush_i(flush),

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

        .mports_i(rob_mportsi),
        .mports_o(rob_mportso),

        .dispatch_i(rob_disi),
        .dispatch_o(rob_diso),

        .commit_i(rob_comi),
        .commit_o(rob_como),

        .rename_commit_i(rename_como),
        .rename_commit_o(rename_comi),

        .jump_i(jumpo),
        .jump_o(jumpi)
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

    mem_m #(1, 16) mem(
        .clk_i(clk),
        .nrst_i(nrst),

        .flush_i(flush),

        .mport_i(0),
        .mport_o(),

        .dispatch_i(res_disi[1]),
        .dispatch_o(res_diso[1]),

        .rport_i(prf_rporto[3:2]),
        .rport_o(prf_rporti[3:2]),

        .commit_i(como[1]),
        .commit_o(comi[1])
    );

    jmp_m #(3) jmp(
        .clk_i(clk),
        .nrst_i(nrst),

        .flush_i(flush),

        .dispatch_i(res_disi[2]),
        .dispatch_o(res_diso[2]),

        .rport_i(prf_rporto[5:4]),
        .rport_o(prf_rporti[5:4]),

        .commit_i(como[2]),
        .commit_o(comi[2])
    );

    pipe_reg_m #(commit_i_t, commit_o_t) commit_pipe_reg [FU_COUNT - 1:0] (
        .clk_i(clk),
        .nrst_i(nrst),

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

    initial begin
        int fd;
        reg [7:0] mem [4095:0];

        clk_rst.RESET();

        fd = $fopen("build/prog.bin", "rb");
        $fread(mem, fd);
        $fclose(fd);
        for (int i = 0; i < 1024; i += 4) ram.mem[i / 4] = {
            mem[i + 3],
            mem[i + 2],
            mem[i + 1],
            mem[i + 0]
        };

        #100000;

        $finish;
    end

endmodule

