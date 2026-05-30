`include "bus/bus.svh"
`include "test/logger.svh"

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

        if (sport_i.addr == ADDRESS) begin
            sport_o.ack = 1;

            if (`SERIAL_ASCII_MODE) begin
                $write("%c", sport_i.data[7:0]);
            end
            else begin
                `DL(log, ("SERIAL: 0x%x", sport_i.data));
            end

            for (int i = 0; i < 10; i++) begin
                wait(clk_i);
                wait(!clk_i);
            end

            sport_o.ack = 0;
        end

        wait(!sport_i.req);
    end

endmodule

