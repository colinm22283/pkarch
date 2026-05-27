module memory_port_m(
    input wire clk_i,
    input wire nrst_i,

    input  memory_port_i_t stream_port_i,
    output memory_port_o_t stream_port_o,

    input  bus_miport_t mport_i,
    output bus_moport_t mport_o
);

    enum logic [1:0] {
        STATE_IDLE,
        STATE_REQ,
        STATE_ACK,
        STATE_DONE
    } state;

    bus_data_t out_data;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            state = STATE_IDLE;

            out_data = 0;
        end
        else begin
            case (state)
                STATE_IDLE: begin
                    if (stream_port_i.req) begin
                        state = STATE_REQ;
                    end
                end

                STATE_REQ: begin
                    if (mport_i.ack) begin
                        state = STATE_ACK;
                    end
                end

                STATE_ACK: begin
                    if (!mport_i.ack) begin
                        state = STATE_DONE;

                        out_data = mport_i.data;
                    end
                end

                STATE_DONE: begin
                    state = STATE_IDLE;
                end
            endcase
        end
    end

    always_comb begin
        stream_port_o.ack = state == STATE_DONE;
        stream_port_o.data = out_data;

        mport_o.req = state == STATE_REQ || state == STATE_ACK;

        mport_o.rw = stream_port_i.rw;
        mport_o.size = stream_port_i.size;
        mport_o.addr = stream_port_i.addr;
        mport_o.size = stream_port_i.size;

        mport_o.seqmst = 0;
    end

endmodule

