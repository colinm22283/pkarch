`timescale 1ns/100ps

`include "fu.svh"
`include "commit.svh"
`include "bus.svh"

module mem_m #(
    parameter WIDTH = 2,
    parameter RES_SIZE = 3
)(
    input wire clk_i,
    input wire nrst_i,

    input wire flush_i,

    input  bus_miport_t mport_i,
    output bus_moport_t mport_o,

    input  res_dispatch_i_t dispatch_i,
    output res_dispatch_o_t dispatch_o,

    input  prf_rport_o_t [WIDTH * 2 - 1:0] rport_i,
    output prf_rport_i_t [WIDTH * 2 - 1:0] rport_o,

    input  commit_o_t [WIDTH - 1:0] commit_i,
    output commit_i_t [WIDTH - 1:0] commit_o
);

    fu_test_i_t fu_testi;
    fu_test_o_t fu_testo;

    fu_dispatch_i_t [WIDTH - 1:0] fu_dispi;
    fu_dispatch_o_t [WIDTH - 1:0] fu_dispo;

    mem_test_m mem_test(
        .test_i(fu_testi),
        .test_o(fu_testo)
    );

    res_station_m #(RES_SIZE, WIDTH) res_stations(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .flush_i(flush_i),

        .res_dispatch_i(dispatch_i),
        .res_dispatch_o(dispatch_o),

        .fu_test_i(fu_testo),
        .fu_test_o(fu_testi),

        .fu_dispatch_i(fu_dispo),
        .fu_dispatch_o(fu_dispi)
    );

    generate
        for (genvar i = 0; i < WIDTH; i++) begin
            mem_fu_m fu(
                .clk_i(clk_i),
                .nrst_i(nrst_i),

                .mport_i(mport_i),
                .mport_o(mport_o),

                .dispatch_i(fu_dispi[i]),
                .dispatch_o(fu_dispo[i]),

                .rport_i(rport_i[i * 2+:2]),
                .rport_o(rport_o[i * 2+:2]),

                .commit_i(commit_i[i]),
                .commit_o(commit_o[i])
            );
        end
    endgenerate

endmodule

