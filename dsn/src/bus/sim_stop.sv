`include "bus.svh"
`include "logger.svh"

module sim_stop_m #(
    parameter ADDRESS = 0
) (
    input wire clk_i,
    input wire nrst_i,

    input  bus_siport_t sport_i,
    output bus_soport_t sport_o
);

    `DL_DEFINE(log, "sim_stop_m", `DL_GREEN, `DL_ENABLE_SIM_STOP);
    `DL_DEFINE(error, "sim_stop_m ERROR", `DL_RED, `DL_ENABLE_SIM_STOP);

    initial begin
        wait(clk_i && sport_i.req && sport_i.addr == ADDRESS);

        if (sport_i.data == 0) begin
            `DL(log,   ("Sim stop with code %0d", sport_i.data));
        end
        else begin
            `DL(error, ("Sim stop with code %0d", sport_i.data));
        end

        $finish;
    end

endmodule
