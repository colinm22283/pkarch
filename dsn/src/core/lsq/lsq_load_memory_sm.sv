module lsq_load_memory_sm_m(
    input  logic clk_i,
    input  logic nrst_i,

    input  bus_miport_t mport_i,
    output bus_moport_t mport_o,

    input  commit_o_t   commit_i,
    output commit_i_t   commit_o,

    input  logic valid_i,
    output logic ready_o,
    input  bus_size_t size_i,
    input  word_t     addr_i,
    input  reg_addr_t isa_addr_i,
    input  prf_addr_t rd_i,
    input  prf_addr_t prev_rd_i,
    input  rob_id_t   rob_id_i
);

    enum logic [1:0] {
        STATE_IDLE,
        STATE_REQ,
        STATE_ACK,
        STATE_COMMIT
    } state_q, state_d;

    bus_size_t size_q, size_d;
    word_t     addr_q, addr_d;
    reg_addr_t isa_addr_q, isa_addr_d;
    prf_addr_t rd_q, rd_d;
    prf_addr_t prev_rd_q, prev_rd_d;
    rob_id_t   rob_id_q, rob_id_d;
    word_t     value_q, value_d;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            state_q    <= STATE_IDLE;

            size_q     <= BUS_SIZE_BYTE;
            addr_q     <= '0;
            isa_addr_q <= REG_ZERO;
            rd_q       <= '0;
            prev_rd_q  <= '0;
            rob_id_q   <= '0;
            value_q    <= '0;
        end
        else begin
            state_q    <= state_d;

            size_q     <= size_d;
            addr_q     <= addr_d;
            isa_addr_q <= isa_addr_d;
            rd_q       <= rd_d;
            prev_rd_q  <= prev_rd_d;
            rob_id_q   <= rob_id_d;
            value_q    <= value_d;
        end
    end

    always_comb begin
        state_d    = state_q;
        size_d     = size_q;
        addr_d     = addr_q;
        isa_addr_d = isa_addr_q;
        rd_d       = rd_q;
        prev_rd_d  = prev_rd_q;
        rob_id_d   = rob_id_q;
        value_d    = value_q;

        ready_o = 1'b0;

        mport_o = '0;

        mport_o.rw = BUS_RW_READ;
        mport_o.size = size_q;
        mport_o.addr = addr_q;
        mport_o.data = value_q;

        commit_o          = '0;
        commit_o.rob_id   = rob_id_q;
        commit_o.isa_addr = isa_addr_q;
        commit_o.rd_a     = 1'b1;
        commit_o.rd       = rd_q;
        commit_o.prev_rd  = prev_rd_q;
        commit_o.value    = value_q;

        case (state_q)
            STATE_IDLE: begin
                ready_o = 1'b1;

                if (valid_i) begin
                    state_d    = STATE_REQ;

                    size_d     = size_i;
                    addr_d     = addr_i;
                    isa_addr_d = isa_addr_i;
                    rd_d       = rd_i;
                    prev_rd_d  = prev_rd_i;
                    rob_id_d   = rob_id_i;
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
                    state_d = STATE_COMMIT;

                    value_d = mport_i.data;
                end
            end

            STATE_COMMIT: begin
                commit_o.valid = 1;

                if (commit_i.ready) begin
                    state_d = STATE_IDLE;
                end
            end
        endcase
    end

endmodule


