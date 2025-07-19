`include "defs.v"

module busint_m #(
    parameter PORT_COUNT = 1
) (
    input wire clk_i,
    input wire nrst_i,

    input  wire [(PORT_COUNT * `BUS_PORT_SIZE) - 1:0] ports_i,
    output reg  [(PORT_COUNT * `BUS_PORT_SIZE) - 1:0] ports_o
);

    reg delay;
    reg req;
    reg [$clog2(PORT_COUNT) - 1:0] req_sel;
    reg ack;
    reg [$clog2(PORT_COUNT) - 1:0] ack_sel;

    always @(posedge clk_i, negedge nrst_i) begin : PORT_SEL
        integer i;

        reg [`BUS_PORT] porti;

        if (!nrst_i) begin
            delay    = 0;
            req      = 0;
            ack      = 0;
            req_sel  = 0;
            ack_sel  = 0;
        end
        else if (clk_i) begin
            if (delay) begin
                delay = 0;
            end
            if (ack) begin
                porti = ports_i[ack_sel * `BUS_PORT_SIZE +: `BUS_PORT_SIZE];
                
                if (!porti[`BUS_ACK]) begin
                    delay = 1;
                    req   = 0;
                    ack   = 0;
                end
            end
            else if (req) begin
                for (i = 0; i < PORT_COUNT; i = i + 1) begin
                    porti = ports_i[i * `BUS_PORT_SIZE +: `BUS_PORT_SIZE];

                    if (porti[`BUS_ACK]) begin
                        ack = 1;
                        ack_sel = i;
                    end
                end
            end
            else begin
                for (i = PORT_COUNT - 1; i >= 0; i = i - 1) begin
                    porti = ports_i[i * `BUS_PORT_SIZE +: `BUS_PORT_SIZE];

                    if (porti[`BUS_REQ]) begin
                        req = 1;
                        req_sel = i;
                    end
                end
            end
        end
    end

    always @(*) begin : OUTPUT
        integer i;

        ports_o <= 0;

        if (ack) begin
            ports_o[req_sel * `BUS_PORT_SIZE +: `BUS_PORT_SIZE]
                <= ports_i[ack_sel * `BUS_PORT_SIZE +: `BUS_PORT_SIZE];

            ports_o[ack_sel * `BUS_PORT_SIZE +: `BUS_PORT_SIZE]
                <= ports_i[req_sel * `BUS_PORT_SIZE +: `BUS_PORT_SIZE];
        end
        else if (req) begin
            for (i = 0; i < PORT_COUNT; i = i + 1) begin
                ports_o[i * `BUS_PORT_SIZE +: `BUS_PORT_SIZE]
                    <= ports_i[req_sel * `BUS_PORT_SIZE +: `BUS_PORT_SIZE];

                ports_o[i * `BUS_PORT_SIZE + `BUS_ACK] <= 0;
            end
        end
    end

endmodule
