`include "bus.svh"
`include "logger.svh"

module serial_m #(
    parameter ADDRESS = 0
) (
    input wire clk_i,
    input wire nrst_i,
    
    input  bus_siport_t sport_i,
    output bus_soport_t sport_o
);

    `DL_DEFINE(log, "serial_m", `DL_GREEN, `DL_ENABLE_SERIAL);

    initial forever begin
        wait(sport_i.req);
        wait(clk_i);
        #1;

        if (sport_i.addr == ADDRESS) begin
            sport_o.ack = 1;

            wait(!clk_i);
            wait(clk_i);

            `DL(log, ("SERIAL: 0x%x", sport_i.data));

            sport_o.ack = 0;
        end

        wait(!sport_i.req);
    end

endmodule

