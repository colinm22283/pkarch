`timescale 1ns/100ps

`include "bus.svh"

module bus_tb();

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
    bus_siport_t sportbi;
    bus_soport_t sportbo;

    busarb_m #(2, 2, 2) arbiter(
        .clk_i(clk),
        .nrst_i(nrst),

        .mports_i({ mportao, mportbo }),
        .mports_o({ mportai, mportbi }),

        .sports_i({ sportao, sportbo }),
        .sports_o({ sportai, sportbi })
    );

    bus_master_m bma(
        .clk_i(clk),
        
        .mport_i(mportai),
        .mport_o(mportao)
    );

    bus_master_m bmb(
        .clk_i(clk),
        
        .mport_i(mportbi),
        .mport_o(mportbo)
    );

    ram_m #(0, 1000) rama(
        .clk_i(clk),
        .nrst_i(nrst),

        .sport_i(sportai),
        .sport_o(sportao)
    );

    ram_m #(1000, 1000) ramb(
        .clk_i(clk),
        .nrst_i(nrst),

        .sport_i(sportbi),
        .sport_o(sportbo)
    );

    initial begin
        bus_addr_t addr;
        bus_data_t write_data;
        bus_data_t read_data;

        clk_rst.RESET();

        bmb.WRITE_WORD(1, 32'hFF00FF00);

        bma.READ_WORD(1, read_data);

        $display(read_data);

        #1000;

        $finish;
    end

    initial begin
        #10000;
        
        $finish;
    end

endmodule

