`timescale 1ns/100ps

`include "lsq.svh"
`include "memory_port.svh"

module lsq_tb();

    wire clk, nrst;

    clk_rst_m clk_rst(
        .clk_o(clk),
        .nrst_o(nrst)
    );

    bus_miport_t mportai;
    bus_moport_t mportao;
    bus_miport_t mportbi;
    bus_moport_t mportbo;

    bus_siport_t sportai;
    bus_soport_t sportao;

    busarb_m #(2, 1, 1) arbiter(
        .clk_i(clk),
        .nrst_i(nrst),

        .mports_i({ mportao, mportbo }),
        .mports_o({ mportai, mportbi }),

        .sports_i({ sportao }),
        .sports_o({ sportai })
    );

    lsq_dispatch_i_t dispatchi;
    lsq_dispatch_o_t dispatcho;

    logic run, complete;

    lsq_m lsq(
        .clk_i(clk),
        .nrst_i(nrst),

        .mports_i({ mportai, mportbi }),
        .mports_o({ mportao, mportbo }),

        .dispatch_i(dispatchi),
        .dispatch_o(dispatcho),

        .commit_i(0),
        .commit_o(),

        .mem_commit_run_i(run),
        .mem_commit_complete_o(complete)
    );

    ram_m #(0, 1000) rama(
        .clk_i(clk),
        .nrst_i(nrst),

        .sport_i(sportai),
        .sport_o(sportao)
    );

    initial begin
        run = 0;
        dispatchi = 0;

        #1000;

        wait(!clk);
        dispatchi.valid = 1;
        dispatchi.rw = BUS_RW_READ;
        dispatchi.size = BUS_SIZE_WORD;
    end

    initial begin
        #100000;

        $finish;
    end

endmodule

