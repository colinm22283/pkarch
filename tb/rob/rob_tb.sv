`timescale 1ns/100ps

`include "isa.svh"

module rob_tb();

    wire clk, nrst;

    clk_rst_m clk_rst(
        .clk_o(clk),
        .nrst_o(nrst)
    );

    rename_dispatch_i_t [RENAME_WIDTH - 1:0] rdisi;
    rename_dispatch_o_t [RENAME_WIDTH - 1:0] rdiso;

    rename_commit_i_t [COMMIT_WIDTH - 1:0] rcomi;
    rename_commit_o_t [COMMIT_WIDTH - 1:0] rcomo;

    rename_m rename(
        .clk_i(clk),
        .nrst_i(nrst),

        .dispatch_i(rdisi),
        .dispatch_o(rdiso),

        .commit_i(rcomi),
        .commit_o(rcomo)
    );

    rob_dispatch_i_t [ROB_DISPATCH_WIDTH - 1:0] disi;
    rob_dispatch_o_t [ROB_DISPATCH_WIDTH - 1:0] diso;

    rob_commit_i_t [ROB_COMMIT_WIDTH - 1:0] comi;
    rob_commit_o_t [ROB_COMMIT_WIDTH - 1:0] como;

    rob_m dut(
        .clk_i(clk),
        .nrst_i(nrst),

        .dispatch_i(disi),
        .dispatch_o(diso),

        .commit_i(comi),
        .commit_o(como),

        .rename_commit_i(rcomo),
        .rename_commit_o(rcomi)
    );



    initial begin
        rob_id_t rob_id [15:0];
        prf_addr_t prf_addr [15:0];

        disi = 0;

        clk_rst.RESET();

        DISPATCH(0, rob_id[0]);
        RDISPATCH(0, REG_S0, prf_addr[0]);
        RDISPATCH(0, REG_S1, prf_addr[1]);
        RDISPATCH_WRITE(0, REG_S2, prf_addr[2]);

        DISPATCH(0, rob_id[0]);
        RDISPATCH(0, REG_S2, prf_addr[3]);
        RDISPATCH(0, REG_S3, prf_addr[4]);
        RDISPATCH_WRITE(0, REG_S4, prf_addr[5]);

        COMMIT(0, rob_id[0], REG_S2, prf_addr[2]);
        COMMIT(0, rob_id[1], REG_S4, prf_addr[5]);

        $display("%d, %d, %d, %d, %d, %d", prf_addr[0], prf_addr[1], prf_addr[2], prf_addr[3], prf_addr[4], prf_addr[5]);

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
        wait(!clk);

        rdisi[index].valid = 1;
        rdisi[index].write = 0;
        rdisi[index].isa_addr = isa_addr;

        wait(rdiso[index].ready);
        wait(clk);
        #1;

        rdisi[index].valid = 0;
        prf_addr = rdiso[index].prf_addr;
    end
    endtask

    task RDISPATCH_WRITE;
        input index;

        input  reg_addr_t isa_addr;
        output prf_addr_t prf_addr;
    begin
        wait(!clk);

        rdisi[index].valid = 1;
        rdisi[index].write = 1;
        rdisi[index].isa_addr = isa_addr;

        wait(rdiso[index].ready);
        wait(clk);
        #1;

        rdisi[index].valid = 0;
        prf_addr = rdiso[index].prf_addr;
    end
    endtask

    task DISPATCH;
        input index;

        output rob_id_t rob_id;
    begin
        wait(!clk);

        disi[index].valid = 1;

        wait(diso[index].ready);
        wait(clk);
        #1;

        rob_id = diso[index].id;
        disi[index].valid = 0;
    end
    endtask

    task COMMIT;
        input index;

        input rob_id_t rob_id;
        input reg_addr_t isa_addr;
        input prf_addr_t prf_addr;
    begin
        wait(!clk);

        comi[index].valid = 1;
        comi[index].rob_id = rob_id;
        comi[index].prf_addr = prf_addr;
        comi[index].isa_addr = isa_addr;

        wait(como[index].ready);
        wait(clk);
        #1;

        comi[index].valid = 0;
    end
    endtask

endmodule

