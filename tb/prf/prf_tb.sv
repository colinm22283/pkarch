`timescale 1ns/100ps

`include "isa.svh"

module prf_tb();

    wire clk, nrst;

    clk_rst_m clk_rst(
        .clk_o(clk),
        .nrst_o(nrst)
    );

    prf_wport_i_t [PRF_WPORTS - 1:0] wports;

    prf_rport_i_t [PRF_RPORTS - 1:0] rportsi;
    prf_rport_o_t [PRF_RPORTS - 1:0] rportso;

    prf_rel_i_t [COMMIT_WIDTH - 1:0] reli;

    prf_m dut(
        .clk_i(clk),
        .nrst_i(nrst),

        .prf_wport_i(wports),

        .prf_rport_i(rportsi),
        .prf_rport_o(rportso),

        .prf_rel_i(reli)
    );

    initial begin
        wports  = 0;
        rportsi = 0;
        rportso = 0;
        reli    = 0;

        clk_rst.RESET();

        fork
            begin
                #1000;

                wait(!clk);

                wports[0].we = 1;
                wports[0].addr = 10;
                wports[0].data = 123;

                wait(clk);
                wait(!clk);

                wports[0].we = 0;
            end
            begin
                wait(!clk);

                rportsi[0].req  = 1;
                rportsi[0].addr = 10;
                wait(clk);
                wait(!clk);
                rportsi[0].req  = 0;

                wait(rportso[0].ack);
                #1;

                $display(rportso[0].data);
            end
        join
    end

    initial begin
        #1000000;
        $finish;
    end

endmodule

