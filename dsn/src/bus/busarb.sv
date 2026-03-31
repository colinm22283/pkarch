`timescale 1ns/100ps

`include "bus.svh"

module busarb_m #(
    parameter MASTER_COUNT = 1,
    parameter SLAVE_COUNT  = 1,
    parameter CROSSBARS    = 1
) (
    input  wire clk_i,
    input  wire nrst_i,

    input  bus_moport_t [MASTER_COUNT - 1:0] mports_i,
    output bus_miport_t [MASTER_COUNT - 1:0] mports_o,

    input  bus_soport_t [SLAVE_COUNT - 1:0] sports_i,
    output bus_siport_t [SLAVE_COUNT - 1:0] sports_o
);

    localparam STATE_READY = 2'b00;
    localparam STATE_REQ   = 2'b01;
    localparam STATE_ACK   = 2'b10;
    localparam STATE_DONE  = 2'b11;

    reg [1:0] state [CROSSBARS - 1:0];

    reg [MASTER_COUNT - 1:0] master_handled;
    reg [SLAVE_COUNT - 1:0]  slave_handled;

    localparam MASTER_SEL_WIDTH = MASTER_COUNT == 1 ? 1 : $clog2(MASTER_COUNT);
    localparam SLAVE_SEL_WIDTH = SLAVE_COUNT == 1 ? 1 : $clog2(SLAVE_COUNT);
    localparam CROSSBAR_SEL_WIDTH = CROSSBARS == 1 ? 1 : $clog2(CROSSBARS);

    reg [MASTER_SEL_WIDTH - 1:0] master_sel [CROSSBARS - 1:0];
    reg [SLAVE_SEL_WIDTH - 1:0]  slave_sel  [CROSSBARS - 1:0];

    localparam CROSSBAR_WIDTH = $clog2(CROSSBARS + 1);

    reg [CROSSBAR_WIDTH - 1:0] crossbar;

    always @(posedge clk_i, negedge nrst_i) begin
        if (!nrst_i) begin : RESET
            integer i;

            master_handled <= 0;
            slave_handled  <= 0;

            for (i = 0; i < CROSSBARS; i = i + 1) begin
                state[i] <= STATE_READY;

                master_sel[i] <= 0;
                slave_sel[i]  <= 0;
            end

            crossbar <= 0;
        end
        else if (clk_i) begin : CLOCK
            integer cb;

            for (cb = 0; cb < CROSSBARS; cb = cb + 1) begin
                case (state[cb])
                    STATE_READY: begin : READY
                        integer i;

                        if (crossbar == CROSSBAR_WIDTH'(cb)) begin
                            for (i = MASTER_COUNT - 1; i >= 0; i = i - 1) begin
                                if (!master_handled[i] && mports_i[i].req) begin
                                    state[cb] = STATE_REQ;

                                    master_sel[cb] = MASTER_SEL_WIDTH'(i);
                                end
                            end

                            if (state[cb] == STATE_REQ) master_handled[master_sel[cb]] = 1;
                        end
                    end

                    STATE_REQ: begin : REQ
                        integer i;

                        if (crossbar == CROSSBAR_WIDTH'(cb)) begin
                            for (i = SLAVE_COUNT - 1; i >= 0; i = i - 1) begin
                                if (!slave_handled[i] && sports_i[i].ack) begin
                                    state[cb] = STATE_ACK;

                                    slave_sel[cb] = SLAVE_SEL_WIDTH'(i);
                                end
                            end

                            if (state[cb] == STATE_ACK) slave_handled[slave_sel[cb]] = 1;
                        end
                    end

                    STATE_ACK: begin
                        if (!sports_i[slave_sel[cb]].ack) begin
                            if (!mports_i[master_sel[cb]].req) begin
                                state[cb] = STATE_DONE;
                            end
                        end
                    end

                    STATE_DONE: begin
                        slave_handled[slave_sel[cb]] = 0;
                        master_handled[master_sel[cb]] = 0;

                        state[cb] = STATE_READY;
                    end
                endcase
            end

            if (state[CROSSBAR_SEL_WIDTH'(crossbar)] == STATE_ACK) begin
                crossbar = 0;
                for (cb = CROSSBARS - 1; cb >= 0; cb = cb - 1) begin
                    if (state[cb] == STATE_READY) crossbar = CROSSBAR_WIDTH'(cb);
                end
            end
        end
    end

    always @(*) begin : COMB
        integer cb;

        sports_o = 0;
        mports_o = 0;

        for (cb = 0; cb < CROSSBARS; cb = cb + 1) begin
            case (state[cb])
                default: ;

                STATE_REQ: begin : REQ_COMB
                    integer i;

                    for (i = 0; i < SLAVE_COUNT; i = i + 1) begin
                        if (!slave_handled[i]) begin
                            sports_o[i] = mports_i[master_sel[cb]];
                        end
                    end
                end

                STATE_ACK: begin
                    sports_o[slave_sel[cb]] = mports_i[master_sel[cb]];

                    mports_o[master_sel[cb]] = sports_i[slave_sel[cb]];
                end
            endcase
        end
    end

endmodule

