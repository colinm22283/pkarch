module lsq_store_memory_sm_m(
    input  logic clk_i,
    input  logic nrst_i,

    input  bus_miport_t mport_i,
    output bus_moport_t mport_o,

    input  logic valid_i,
    output logic ready_o,
    output logic done_o,
    input  bus_size_t size_i,
    input  word_t     addr_i,
    input  word_t     value_i
);

    enum logic [1:0] {
        STATE_IDLE,
        STATE_REQ,
        STATE_ACK
    } state_q, state_d;

    bus_size_t size_q, size_d;
    word_t     addr_q, addr_d;
    word_t     value_q, value_d;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            state_q <= STATE_IDLE;

            size_q  <= BUS_SIZE_BYTE;
            addr_q  <= '0;
            value_q <= '0;
        end
        else begin
            state_q <= state_d;

            size_q  <= size_d;
            addr_q  <= addr_d;
            value_q <= value_d;
        end
    end

    always_comb begin
        state_d = state_q;
        size_d  = size_q;
        addr_d  = addr_q;
        value_d = value_q;

        ready_o = 1'b0;
        done_o  = 1'b0;

        mport_o = '0;

        mport_o.rw = BUS_RW_WRITE;
        mport_o.size = size_q;
        mport_o.addr = addr_q;
        mport_o.data = value_q;

        case (state_q)
            STATE_IDLE: begin
                ready_o = 1'b1;

                if (valid_i) begin
                    state_d = STATE_REQ;

                    size_d  = size_i;
                    addr_d  = addr_i;
                    value_d = value_i;
                end
            end

            STATE_REQ: begin
                mport_o.req = 1'b1;

                if (mport_i.ack) begin
                    state_d = STATE_ACK;
                end
            end

            STATE_ACK: begin
                mport_o.req = 1'b1;

                if (!mport_i.ack) begin
                    done_o = 1'b1;

                    state_d = STATE_IDLE;
                end
            end

            default: begin
                state_d = STATE_IDLE;
            end
        endcase
    end

endmodule

