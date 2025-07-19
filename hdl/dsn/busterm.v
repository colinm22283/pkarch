`include "defs.v"

module busterm_m #(
    parameter ADDRESS = 0,
    parameter SIZE    = 1
) (
    input  wire [`BUS_PORT] port_i,
    output wire [`BUS_PORT] port_o,

    input  wire req_i,
    output wire ack_o,

    output wire req_o,
    input  wire ack_i,

    input  wire        rw_i,
    input  wire [1:0]  size_i,

    output wire        rw_o,
    output wire [1:0]  size_o,

    output wire [31:0] addr_o,
    input  wire [31:0] addr_i,

    output wire [31:0] data_o,
    input  wire [31:0] data_i
);

    assign ack_o  = port_i[`BUS_ACK];
    assign req_o  = port_i[`BUS_REQ] && addr_o >= ADDRESS && addr_o < ADDRESS + SIZE;
    assign rw_o   = port_i[`BUS_RW];
    assign size_o = port_i[`BUS_SIZE];
    assign addr_o = port_i[`BUS_ADDR];
    assign data_o = port_i[`BUS_DATA];

    assign port_o[`BUS_ACK]  = ack_i;
    assign port_o[`BUS_REQ]  = req_i;
    assign port_o[`BUS_RW]   = rw_i;
    assign port_o[`BUS_SIZE] = size_i;
    assign port_o[`BUS_ADDR] = addr_i;
    assign port_o[`BUS_DATA] = data_i;

endmodule
