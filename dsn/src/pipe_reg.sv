module pipe_reg_m #(type in_t = logic, type out_t = logic) (
    input wire clk_i,
    input wire nrst_i,

    input  in_t  s_i,
    output out_t s_o,

    input  out_t m_i,
    output in_t  m_o
);

    logic valid;
    in_t mem;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
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

    always_comb begin
        s_o.ready = !valid || m_i.ready;

        m_o = mem;
        m_o.valid = valid;
    end

endmodule

