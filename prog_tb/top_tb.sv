`timescale 1ns/100ps

`include "isa.svh"
`include "bus/icache.svh"

module top_tb();

    wire clk, nrst;

    clk_rst_m clk_rst(
        .clk_o(clk),
        .nrst_o(nrst)
    );

    bus_siport_t sportai;
    bus_soport_t sportao;

    bus_siport_t sportbi;
    bus_soport_t sportbo;

    bus_siport_t sportci;
    bus_soport_t sportco;

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

    top_m #(3) top(
        .clk_i(clk),
        .nrst_i(nrst),

        .mports_i({ sportao, sportbo, sportco }),
        .mports_o({ sportai, sportbi, sportci })
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

        #1000000;

        $finish;
    end

endmodule

