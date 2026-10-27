`timescale 1ns/100ps

`include "isa.svh"
`include "bus/icache.svh"

module top_tb();

    parameter integer ROM_SIZE = 4096 * 4;
    parameter integer RAM_SIZE = 32'h20000;

    string filename;

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

    bus_siport_t sportdi;
    bus_soport_t sportdo;

    bus_siport_t sportei;
    bus_soport_t sporteo;

    bus_siport_t sportfi;
    bus_soport_t sportfo;

    bus_siport_t sportgi;
    bus_soport_t sportgo;

    dummy_slave_m #(32'h00000000, 32'h10000000) dummy1(
        .clk_i(clk),
        .nrst_i(nrst),

        .sport_i(sportdi),
        .sport_o(sportdo)
    );

    ram_m #(32'h01000000, RAM_SIZE) ram(
        .clk_i(clk),
        .nrst_i(nrst),

        .sport_i(sportfi),
        .sport_o(sportfo)
    );

    serial_m #(32'h10000000) serial(
        .clk_i(clk),
        .nrst_i(nrst),

        .sport_i(sportbi),
        .sport_o(sportbo),

        .in_valid_i(1'b0),
        .in_ready_o(),
        .in_data_i(8'h00)
    );

    sim_stop_m #(32'h10000004) sim_stop(
        .clk_i(clk),
        .nrst_i(nrst),
        
        .sport_i(sportci),
        .sport_o(sportco),

        .commit_count_i(top.rob.commit_count_q)
    );

    dummy_slave_m #(32'h10000004, 32'h80000000 - 32'h10000004) dummy2(
        .clk_i(clk),
        .nrst_i(nrst),

        .sport_i(sportei),
        .sport_o(sporteo)
    );

    ram_m #(32'h80000000, ROM_SIZE) rom(
        .clk_i(clk),
        .nrst_i(nrst),

        .sport_i(sportai),
        .sport_o(sportao)
    );

    dummy_slave_m #(32'h80000000 + ROM_SIZE, 32'hFFFFFFFF - 32'h80000000 - ROM_SIZE) dummy3(
        .clk_i(clk),
        .nrst_i(nrst),

        .sport_i(sportgi),
        .sport_o(sportgo)
    );

    top_m #(7) top(
        .clk_i(clk),
        .nrst_i(nrst),

        .mports_i({ sportao, sportbo, sportco, sportdo, sporteo, sportfo, sportgo }),
        .mports_o({ sportai, sportbi, sportci, sportdi, sportei, sportfi, sportgi })
    );

    initial begin
        int fd;
        reg [7:0] mem [ROM_SIZE - 1:0];

        clk_rst.RESET();

        $value$plusargs("ROM=%s", filename);

        fd = $fopen(filename, "rb");
        $fread(mem, fd);
        $fclose(fd);
        for (int i = 0; i < ROM_SIZE; i += 4) rom.mem[i / 4] = {
            mem[i + 3],
            mem[i + 2],
            mem[i + 1],
            mem[i + 0]
        };

        #1000000;

        $finish;
    end

endmodule


