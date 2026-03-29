`timescale 1ns/100ps

`include "isa.svh"

module no_fetch_tb();

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

    alu_m #(1, 3) alu(
        .clk_i(clk),
        .nrst_i(nrst),

        .dispatch_i(fu_disi),
        .dispatch_o(fu_diso),

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

    rob_id_t [1:0] disp_rob_id;
    prf_addr_t [5:0] prf_addrs;

    initial begin
        clk_rst.RESET();

        #100;

        DISPATCH(0, disp_rob_id[0]);

        RDISPATCH(0, REG_S0, prf_addrs[0]);
        RDISPATCH(0, REG_S1, prf_addrs[1]);
        RDISPATCH_WRITE(0, REG_S2, prf_addrs[2]);

        prf.mem[prf_addrs[0]].data  = 1;
        prf.mem[prf_addrs[1]].data  = 1;
        prf.mem[prf_addrs[0]].valid = 1;
        prf.mem[prf_addrs[1]].valid = 1;
        #100;

        $display("0x%h + 0x%h => 0x%h", prf_addrs[0], prf_addrs[1], prf_addrs[2]);

        wait(!clk);
        fu_disi.valid = 1;

        fu_disi.dec_inst.opcode = 7'b0110011;
        fu_disi.dec_inst.funct  = FUNCT_ADD;
        fu_disi.dec_inst.rs1    = REG_S0;
        fu_disi.dec_inst.rs2    = REG_S1;
        fu_disi.dec_inst.rd     = REG_S2;

        fu_disi.rob_id = disp_rob_id[0];

        fu_disi.rs1 = prf_addrs[0];
        fu_disi.rs2 = prf_addrs[1];
        fu_disi.rd  = prf_addrs[2];
        wait(fu_diso.ready && fu_disi.valid);
        wait(clk);
        #1;
        fu_disi.valid = 0;

        DISPATCH(0, disp_rob_id[1]);

        RDISPATCH(0, REG_S0, prf_addrs[3]);
        RDISPATCH(0, REG_S2, prf_addrs[4]);
        RDISPATCH_WRITE(0, REG_S2, prf_addrs[5]);

        $display("0x%h + 0x%h => 0x%h", prf_addrs[3], prf_addrs[4], prf_addrs[5]);

        wait(!clk);
        fu_disi.valid = 1;

        fu_disi.dec_inst.opcode = 7'b0110011;
        fu_disi.dec_inst.funct  = FUNCT_ADD;
        fu_disi.dec_inst.rs1    = REG_S0;
        fu_disi.dec_inst.rs2    = REG_S2;
        fu_disi.dec_inst.rd     = REG_S2;

        fu_disi.rob_id = disp_rob_id[1];

        fu_disi.rs1 = prf_addrs[3];
        fu_disi.rs2 = prf_addrs[4];
        fu_disi.rd  = prf_addrs[5];
        wait(fu_diso.ready && fu_disi.valid);
        wait(clk);
        #1;
        fu_disi.valid = 0;

        #3000;

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

