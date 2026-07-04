`include "bus/bus.svh"
`include "bus/icache.svh"

module icache_6_4_2_m(
    input wire clk_i,
    input wire nrst_i,

    input  icache_i_t icache_i,
    output icache_o_t icache_o,

    input  bus_miport_t mport_i,
    output bus_moport_t mport_o
);

    icache_m #(2, 2, 2) icache(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .icache_i(icache_i),
        .icache_o(icache_o),

        .mport_i(mport_i),
        .mport_o(mport_o)
    );

endmodule

