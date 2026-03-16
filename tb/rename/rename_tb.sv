`timescale 1ns/100ps

`include "rename.svh"

module rename_tb();

    wire clk, nrst;

    clk_rst_m clk_rst(
        .clk_o(clk),
        .nrst_o(nrst)
    );

    rename_dispatch_i_t [RENAME_WIDTH - 1:0] disi;
    rename_dispatch_o_t [RENAME_WIDTH - 1:0] diso;

    rename_commit_i_t [COMMIT_WIDTH - 1:0] comi;
    rename_commit_o_t [COMMIT_WIDTH - 1:0] como;

    rename_m rename(
        .clk_i(clk),
        .nrst_i(nrst),

        .dispatch_i(disi),
        .dispatch_o(diso),

        .commit_i(comi),
        .commit_o(como)
    );

    initial begin
        prf_addr_t prf0, prf1, prf2;

        disi = 0;
        diso = 0;

        clk_rst.RESET();

        DISPATCH(0, REG_A1, prf0);
        $display("PRF ADDR: %d", prf0);

        DISPATCH(1, REG_A1, prf1);
        $display("PRF ADDR: %d", prf1);

        COMMIT(1, prf0);

        DISPATCH(0, REG_A1, prf2);
        $display("PRF ADDR: %d", prf2);

        COMMIT(0, prf1);
        COMMIT(1, prf2);

        DISPATCH(0, REG_A1, prf2);
        $display("PRF ADDR: %d", prf2);

        #1000;

        $finish;
    end

    initial begin
        #10000;

        $display("TIMEOUT!!!");

        $finish;
    end

    task DISPATCH;
        input index;

        input  reg_addr_t isa_addr;
        output prf_addr_t prf_addr;
    begin
        wait(!clk);

        disi[index].valid = 1;
        disi[index].isa_addr = isa_addr;

        wait(diso[index].ready);
        wait(clk);
        #1;

        disi[index].valid = 0;
        prf_addr = diso[index].prf_addr;
    end
    endtask

    task COMMIT;
        input index;

        input prf_addr_t prf_addr;
    begin
        wait(!clk);

        comi[index].valid = 1;
        comi[index].prf_addr = prf_addr;

        wait(como[index].ready);
        wait(clk);
        #1;

        comi[index].valid = 0;
    end
    endtask

endmodule

