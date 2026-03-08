// `include "bus/defs.v"

module busslave_m #(
    parameter ADDRESS = 0,
    parameter SIZE = 1
) (
    input  wire [`BUS_SIPORT] sport_i,
    output wire [`BUS_SOPORT] sport_o,

    output wire req_o,
    input  wire ack_i,

    output wire [1:0] size_o,
    output wire       rw_o,

    output wire [`BUS_ADDR_PORT] addr_o,
    output wire [`BUS_DATA_PORT] data_o,
    input  wire [`BUS_DATA_PORT] data_i
);

    wire [`BUS_ADDR_PORT] alt_addr;
    assign alt_addr = sport_i[`BUS_SI_ADDR] - ADDRESS;

    assign req_o = sport_i[`BUS_SI_REQ] && alt_addr >= 0 && alt_addr < SIZE;

    assign size_o = sport_i[`BUS_SI_SIZE];
    assign rw_o = sport_i[`BUS_SI_RW];

    assign addr_o = alt_addr;
    assign data_o = sport_i[`BUS_SI_DATA];

    assign sport_o[`BUS_SO_DATA]   = data_i;
    assign sport_o[`BUS_SO_ACK]    = ack_i;
    assign sport_o[`BUS_SO_SEQSLV] = 1'b0;

endmodule
