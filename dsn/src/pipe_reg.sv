`include "core/lsq.svh"
`include "core/commit.svh"

module pipe_reg_lsq_m(
    input wire clk_i,
    input wire nrst_i,

    input wire flush_i,

    input  lsq_dispatch_i_t  s_i,
    output lsq_dispatch_o_t s_o,

    input  lsq_dispatch_o_t m_i,
    output lsq_dispatch_i_t  m_o
);

    logic valid;
    lsq_dispatch_i_t mem;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            valid = 0;
        end
        else begin
            if (flush_i) begin
                valid = 0;
            end
            else begin
                if (m_o.valid && m_i.ready) begin
                    valid = 0;
                end

                if (s_i.valid && s_o.ready) begin
                    valid = 1;
                    mem   = s_i;
                end
            end
        end
    end

    always_comb begin
        s_o.ready = !valid || m_i.ready;

        m_o = mem;
        m_o.valid = valid && !flush_i;
    end

endmodule

module pipe_reg_commit_m(
    input wire clk_i,
    input wire nrst_i,

    input wire flush_i,

    input  commit_i_t  s_i,
    output commit_o_t s_o,

    input  commit_o_t m_i,
    output commit_i_t  m_o
);

    logic valid;
    commit_i_t mem;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            valid = 0;
        end
        else begin
            if (flush_i) begin
                valid = 0;
            end
            else begin
                if (m_o.valid && m_i.ready) begin
                    valid = 0;
                end

                if (s_i.valid && s_o.ready) begin
                    valid = 1;
                    mem   = s_i;
                end
            end
        end
    end

    always_comb begin
        s_o.ready = !valid || m_i.ready;

        m_o = mem;
        m_o.valid = valid && !flush_i;
    end

endmodule


