`timescale 1ns/100ps

`include "bus/bus.svh"

module siport_breakout_m(
    input  bus_siport_t sport_i
);

    bus_rw_t rw;
    bus_size_t size;
    logic seqmst;
    logic req;
    bus_addr_t addr;
    bus_data_t data;

    assign rw = sport_i.rw;
    assign size = sport_i.size;
    assign seqmst = sport_i.seqmst;
    assign req = sport_i.req;
    assign addr = sport_i.addr;
    assign data = sport_i.data;

endmodule

