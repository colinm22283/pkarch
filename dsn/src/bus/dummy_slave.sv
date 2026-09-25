module dummy_slave_m #(
    parameter ADDRESS = 0,
    parameter SIZE    = 1
) (
    input  logic clk_i,
    input  logic nrst_i,

    input  bus_siport_t sport_i,
    output bus_soport_t sport_o
);

    enum logic [1:0] {
        STATE_IDLE,
        STATE_ACK,
        STATE_WAIT
    } state_q;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            state_q <= STATE_IDLE;

            sport_o <= '0;
        end
        else begin
            case (state_q)
                STATE_IDLE: begin
                    if (sport_i.req && sport_i.addr - ADDRESS < SIZE) begin
                        state_q <= STATE_ACK;

                        sport_o.ack <= 1'b1;
                    end
                end

                STATE_ACK: begin
                    state_q <= STATE_WAIT;

                    sport_o.ack <= 1'b0;
                end
                
                STATE_WAIT: begin
                    if (!sport_i.req) begin
                        state_q <= STATE_IDLE;
                    end
                end

                default: begin
                    state_q <= STATE_IDLE;
                end
            endcase
        end
    end

endmodule

