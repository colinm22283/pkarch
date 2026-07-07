`timescale 1ns/100ps

`include "fu/fu.svh"
`include "core/commit.svh"
`include "core/lsq.svh"
`include "bus/bus.svh"

module mem_m #(
    parameter RES_SIZE = 3
)(
    input wire clk_i,
    input wire nrst_i,

    input wire flush_i,

    input  res_dispatch_i_t dispatch_i,
    output res_dispatch_o_t dispatch_o,

    input  prf_rport_o_t [1:0] rport_i,
    output prf_rport_i_t [1:0] rport_o,

    input  lsq_dispatch_o_t lsq_dispatch_i,
    output lsq_dispatch_i_t lsq_dispatch_o
);

    fu_test_i_t fu_testi;
    fu_test_o_t fu_testo;

    fu_dispatch_i_t fu_dispi;
    fu_dispatch_o_t fu_dispo;

    mem_test_m mem_test(
        .test_i(fu_testi),
        .test_o(fu_testo)
    );

    res_station_m #(RES_SIZE, 1) res_stations(
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

    mem_fu_m fu(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .flush_i(flush_i),

        .dispatch_i(fu_dispi),
        .dispatch_o(fu_dispo),

        .rport_i(rport_i),
        .rport_o(rport_o),

        .lsq_dispatch_i(lsq_dispatch_i),
        .lsq_dispatch_o(lsq_dispatch_o)
    );

endmodule

