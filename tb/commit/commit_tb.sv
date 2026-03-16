`timescale 1ns/100ps

`include "isa.svh"

module commit_tb();

    wire clk, nrst;

    clk_rst_m clk_rst(
        .clk_o(clk),
        .nrst_o(nrst)
    );

    commit_i_t [FU_COUNT - 1:0] commiti;
    commit_o_t [FU_COUNT - 1:0] commito;

    rename_dispatch_i_t [RENAME_WIDTH - 1:0] rename_dispatchi;
    rename_dispatch_o_t [RENAME_WIDTH - 1:0] rename_dispatcho;

    rename_commit_i_t [COMMIT_WIDTH - 1:0] rename_commiti;
    rename_commit_o_t [COMMIT_WIDTH - 1:0] rename_commito;

    prf_wport_i_t [PRF_WPORTS - 1:0] prf_wporti;

    rename_m rename(
        .clk_i(clk),
        .nrst_i(nrst),

        .dispatch_i(rename_dispatchi),
        .dispatch_o(rename_dispatcho),

        .commit_i(rename_commiti),
        .commit_o(rename_commito)
    );

    prf_m prf(
        .clk_i(clk),
        .nrst_i(nrst),

        .prf_wport_i(prf_wporti)
    );

    commit_m commit(
        .clk_i(clk),
        .nrst_i(nrst),

        .commit_i(commiti),
        .commit_o(commito),

        .prf_wport_o(prf_wporti)
    );

    initial begin
        prf_addr_t rs1_addr, rs2_addr, rd_addr;

        clk_rst.RESET();

        DISPATCH(0, REG_S0, rs1_addr);
        DISPATCH(0, REG_S1, rs2_addr);
        DISPATCH(0, REG_S2, rd_addr);

        clk_rst.WAIT_CYCLES(3);

        $finish;
    end

    initial begin
        #1000;

        $display("TIMEOUT!!!");

        $finish;
    end

    task DISPATCH;
        input index;

        input  reg_addr_t isa_addr;
        output prf_addr_t prf_addr;
    begin
        wait(!clk);

        rename_dispatchi[index].valid = 1;
        rename_dispatchi[index].isa_addr = isa_addr;

        wait(rename_dispatcho[index].ready);
        wait(clk);
        #1;

        rename_dispatchi[index].valid = 0;
        prf_addr = rename_dispatcho[index].prf_addr;
    end
    endtask

endmodule

