`include "core/lsq.svh"

module pipeline_lsq_dis_m #(
    parameter integer LENGTH = 1
) (
    input  logic clk_i,
    input  logic nrst_i,

    input  logic flush_i,

    input  lsq_dispatch_i_t  s_i,
    output lsq_dispatch_o_t s_o,

    input  lsq_dispatch_o_t m_i,
    output lsq_dispatch_i_t  m_o
);

    lsq_dispatch_i_t disi [LENGTH:0];
    lsq_dispatch_o_t diso [LENGTH:0];

    generate
        for (genvar i = 0; i < LENGTH; i++) begin
            pipe_reg_lsq_dis_m pipe_reg(
                .clk_i(clk_i),
                .nrst_i(nrst_i),
                
                .flush_i(flush_i),

                .s_i(disi[i]),
                .s_o(diso[i]),

                .m_i(diso[i + 1]),
                .m_o(disi[i + 1])
            );
        end
    endgenerate

    assign disi[0]      = s_i;
    assign s_o          = diso[0];
    assign diso[LENGTH] = m_i;
    assign m_o          = disi[LENGTH];

endmodule

