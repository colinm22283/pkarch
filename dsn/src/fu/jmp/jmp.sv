`timescale 1ns/100ps

`include "fu.svh"
`include "commit.svh"

module jmp_m #(
    parameter RES_SIZE = 3
)(
    input wire clk_i,
    input wire nrst_i,

    input  res_dispatch_i_t dispatch_i,
    output res_dispatch_o_t dispatch_o,

    input  prf_rport_o_t [1:0] rport_i,
    output prf_rport_i_t [1:0] rport_o,

    input  commit_o_t commit_i,
    output commit_i_t commit_o
);

    fu_test_i_t fu_testi;
    fu_test_o_t fu_testo;

    fu_dispatch_i_t fu_dispi;
    fu_dispatch_o_t fu_dispo;

    jmp_test_m alu_test(
        .test_i(fu_testi),
        .test_o(fu_testo)
    );

    res_station_m #(RES_SIZE, 1) res_stations(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .res_dispatch_i(dispatch_i),
        .res_dispatch_o(dispatch_o),

        .fu_test_i(fu_testo),
        .fu_test_o(fu_testi),

        .fu_dispatch_i(fu_dispo),
        .fu_dispatch_o(fu_dispi)
    );

    jmp_fu_m fu(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .dispatch_i(fu_dispi),
        .dispatch_o(fu_dispo),

        .rport_i(rport_i),
        .rport_o(rport_o),

        .commit_i(commit_i),
        .commit_o(commit_o)
    );

endmodule

