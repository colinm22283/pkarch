`timescale 1ns/100ps

`include "isa.svh"

module top_tb();

    wire clk, nrst;

    clk_rst_m clk_rst(
        .clk_o(clk),
        .nrst_o(nrst)
    );

    dispatch_i_t [DISPATCH_WIDTH - 1:0] dispatchi;
    dispatch_o_t [DISPATCH_WIDTH - 1:0] dispatcho;

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

    commit_i_t comi, reg_comi;
    commit_o_t como, reg_como;

    dispatch_m dispatch(
        .clk_i(clk),
        .nrst_i(nrst),

        .dispatch_i(dispatchi),
        .dispatch_o(dispatcho),

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

        .dispatch_i(rename_disi),
        .dispatch_o(rename_diso),

        .commit_i(rename_comi),
        .commit_o(rename_como),

        .prf_rel_o(prf_reli)
    );

    rob_m rob(
        .clk_i(clk),
        .nrst_i(nrst),

        .dispatch_i(rob_disi),
        .dispatch_o(rob_diso),

        .commit_i(rob_comi),
        .commit_o(rob_como),

        .rename_commit_i(rename_como),
        .rename_commit_o(rename_comi)
    );

    prf_m prf(
        .clk_i(clk),
        .nrst_i(nrst),

        .prf_wport_i(prf_wporti),

        .prf_rport_i(prf_rporti),
        .prf_rport_o(prf_rporto),

        .prf_rel_i(prf_reli)
    );

    alu_m #(1, 3) alu(
        .clk_i(clk),
        .nrst_i(nrst),

        .dispatch_i(res_disi),
        .dispatch_o(res_diso),

        .rport_i(prf_rporto),
        .rport_o(prf_rporti),

        .commit_i(como),
        .commit_o(comi)
    );

    pipe_reg_m #(commit_i_t, commit_o_t) commit_pipe_reg(
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
        dec_inst_t dec_inst;

        dispatchi = 0;

        clk_rst.RESET();

        #100;

        prf.mem[0].data  = 1;
        prf.mem[1].data  = 1;
        prf.mem[0].valid = 1;
        prf.mem[1].valid = 1;

        dec_inst.opcode = 7'b0110011;
        dec_inst.funct  = FUNCT_ADD;
        dec_inst.rs1    = REG_S0;
        dec_inst.rs2    = REG_S1;
        dec_inst.rd     = REG_S2;
        DISPATCH(0, dec_inst);

        for (int i = 0; i < 2; i++) begin
            dec_inst.opcode = 7'b0110011;
            dec_inst.funct  = FUNCT_ADD;
            dec_inst.rs1    = REG_S1;
            dec_inst.rs2    = REG_S2;
            dec_inst.rd     = REG_S2;
            DISPATCH(0, dec_inst);
        end

        #3000;

        $finish;
    end

    task DISPATCH;
        input index;

        input dec_inst_t dec_inst;
    begin
        wait(!clk);
        dispatchi[index].valid = 1;
        dispatchi[index].dec_inst = dec_inst;
        wait(dispatcho[index].ready);
        wait(!clk);
        wait(clk);
        #1;
        dispatchi[index].valid = 0;
    end
    endtask

    initial begin
        #10000;

        $display("TIMEOUT!!!");

        $finish;
    end

endmodule

