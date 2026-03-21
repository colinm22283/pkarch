`timescale 1ns/100ps

`include "isa.svh"

module top_tb();

    wire clk, nrst;

    clk_rst_m clk_rst(
        .clk_o(clk),
        .nrst_o(nrst)
    );

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

    fu_dispatch_i_t fu_disi;
    fu_dispatch_o_t fu_diso;

    commit_i_t comi, reg_comi;
    commit_o_t como, reg_como;

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

    alu_fu_m alu_fu(
        .clk_i(clk),
        .nrst_i(nrst),

        .dispatch_i(fu_disi),
        .dispatch_o(fu_diso),

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

    bit run_fu;
    rob_id_t disp_rob_id;
    prf_addr_t [2:0] prf_addrs;

    always_comb begin
        fu_disi.valid = run_fu && prf_rporto[0].valid && prf_rporto[1].valid;

        fu_disi.dec_inst.opcode = 7'b0110011;
        fu_disi.dec_inst.funct  = FUNCT_ADD;
        fu_disi.dec_inst.rs1    = REG_S0;
        fu_disi.dec_inst.rs2    = REG_S1;
        fu_disi.dec_inst.rd     = REG_S2;

        fu_disi.rob_id = disp_rob_id;

        fu_disi.rs1 = prf_addrs[0];
        fu_disi.rs2 = prf_addrs[1];
        fu_disi.rd  = prf_addrs[2];

        fu_disi.rs1_v = prf_rporto[0].data;
        fu_disi.rs2_v = prf_rporto[1].data;

        prf_rporti[0].addr = fu_disi.rs1;
        prf_rporti[1].addr = fu_disi.rs2;
    end

    initial begin
        run_fu = 0;

        clk_rst.RESET();

        #100;

        DISPATCH(0, disp_rob_id);

        RDISPATCH(0, REG_S0, prf_addrs[0]);
        RDISPATCH(0, REG_S1, prf_addrs[1]);
        RDISPATCH_WRITE(0, REG_S2, prf_addrs[2]);

        prf.mem[prf_addrs[0]].data  = 10;
        prf.mem[prf_addrs[1]].data  = 20;
        prf.mem[prf_addrs[0]].valid = 1;
        prf.mem[prf_addrs[1]].valid = 1;
        #100;

        wait(!clk);
        run_fu = 1;
        wait(fu_diso.ready && fu_disi.valid);
        wait(clk);
        #1;
        run_fu = 0;

        DISPATCH(0, disp_rob_id);

        RDISPATCH(0, REG_S0, prf_addrs[0]);
        RDISPATCH(0, REG_S2, prf_addrs[1]);
        RDISPATCH_WRITE(0, REG_S2, prf_addrs[2]);

        #100;

        wait(!clk);
        run_fu = 1;
        wait(fu_diso.ready && fu_disi.valid);
        wait(clk);
        #1;
        run_fu = 0;

        #1000;

        $finish;
    end

    initial begin
        #10000;

        $display("TIMEOUT!!!");

        $finish;
    end

    task RDISPATCH;
        input index;

        input  reg_addr_t isa_addr;
        output prf_addr_t prf_addr;
    begin
        $display("RDISPATCH()");

        wait(!clk);

        rename_disi[index].valid = 1;
        rename_disi[index].write = 0;
        rename_disi[index].isa_addr = isa_addr;

        wait(rename_diso[index].ready);
        wait(clk);
        #1;

        rename_disi[index].valid = 0;
        prf_addr = rename_diso[index].prf_addr;
    end
    endtask

    task RDISPATCH_WRITE;
        input index;

        input  reg_addr_t isa_addr;
        output prf_addr_t prf_addr;
    begin
        $display("RDISPATCH_WRITE()");

        wait(!clk);

        rename_disi[index].valid = 1;
        rename_disi[index].write = 1;
        rename_disi[index].isa_addr = isa_addr;

        wait(rename_diso[index].ready);
        wait(clk);
        #1;

        rename_disi[index].valid = 0;
        prf_addr = rename_diso[index].prf_addr;
    end
    endtask

    task DISPATCH;
        input index;

        output rob_id_t rob_id;
    begin
        $display("DISPATCH()");

        wait(!clk);

        rob_disi[index].valid = 1;

        wait(rob_diso[index].ready);
        wait(clk);
        #1;

        rob_id = rob_diso[index].id;
        rob_disi[index].valid = 0;
    end
    endtask

endmodule

