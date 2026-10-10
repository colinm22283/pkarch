`include "fu/issue_queue.svh"
`include "core/pc.svh"
`include "core/rob.svh"
`include "core/commit.svh"
`include "core/lsq.svh"
`include "fu/issue_queue.svh"
`include "isa.svh"

module intmul_m(
    input  logic clk_i,
    input  logic nrst_i,

    input  logic flush_i,

    input  iq_commit_o_t dispatch_i,
    output iq_commit_i_t dispatch_o,

    input  commit_o_t commit_i,
    output commit_i_t commit_o
);

    logic signed [63:0] mult_out;
    funct_t             funct_out;
    logic a_unsigned, b_unsigned;

    always_comb begin
        case (dispatch_i.data.dec_inst.funct)
            FUNCT_MULSU: begin
                a_unsigned = 1'b0;
                b_unsigned = 1'b1;
            end

            FUNCT_MULHU: begin
                a_unsigned = 1'b1;
                b_unsigned = 1'b1;
            end

            default: begin
                a_unsigned = 1'b0;
                b_unsigned = 1'b0;
            end
        endcase
    end

    bw_mult_m #(
        .WIDTH(32),
        .STAGES({ 16 { 2'b10 } }),
        .EXTRA_SIZE(
            $bits(rob_id_t) +
            $bits(reg_addr_t) +
            $bits(bit) +
            $bits(prf_addr_t) +
            $bits(prf_addr_t) +
            $bits(funct_t)
        )
    ) multiplier(
        .clk_i(clk_i),
        .nrst_i(nrst_i),

        .flush_i(flush_i),

        .valid_i(dispatch_i.valid),
        .ready_o(dispatch_o.ready),

        .a_unsigned_i(a_unsigned),
        .b_unsigned_i(b_unsigned),

        .a_i(dispatch_i.data.rs1_v),
        .b_i(dispatch_i.data.rs2_v),
        .extra_i({
            dispatch_i.data.rob_id,
            dispatch_i.data.isa_addr,
            dispatch_i.data.dec_inst.rd_a,
            dispatch_i.data.rd,
            dispatch_i.data.prev_rd,
            dispatch_i.data.dec_inst.funct
        }),

        .valid_o(commit_o.valid),
        .ready_i(commit_i.ready),
        
        .y_o(mult_out),
        .extra_o({
            commit_o.rob_id,
            commit_o.isa_addr,
            commit_o.rd_a,
            commit_o.rd,
            commit_o.prev_rd,
            funct_out
        })
    );

    always_comb begin
        if (funct_out == FUNCT_MULH || funct_out == FUNCT_MULHU) begin
            commit_o.value = mult_out[63:32];
        end
        else begin
            commit_o.value = mult_out[31:0];
        end
    end

`ifdef COMMIT_PC_ENABLE
    assign commit_o.pc       = '0;
`endif


endmodule


