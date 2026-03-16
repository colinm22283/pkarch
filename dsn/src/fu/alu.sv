`include "fu.svh"
`include "commit.svh"

module alu_fu_m(
    input wire clk_i,
    input wire nrst_i,

    input  fu_dispatch_i_t dispatch_i,
    output fu_dispatch_o_t dispatch_o,

    input  commit_o_t commit_i,
    output commit_i_t commit_o
);

    word_t a, b;
    word_t y;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
        end
        else begin
            if (dispatch_i.valid && dispatch_o.ready) begin
                
            end
        end
    end

    always_comb begin
        commit_o.valid = dispatch_i.valid && dispatch_o.ready;

        commit_o.rob_id = dispatch_i.rob_id;
        commit_o.rd     = dispatch_i.rd;
        commit_o.value  = y;
    end

    always_comb begin
        case (dispatch_i.dec_inst.opcode)
            7'b0110011, 7'b0010011: dispatch_o.ready = commit_i.ready;
            
            default: dispatch_o.ready = 1'b0;
        endcase

        a = dispatch_i.rs1_v;

        case (dispatch_i.dec_inst.opcode)
            7'b0110011: begin
                b = dispatch_i.rs1_v;
            end

            7'b0010011: begin
                b = dispatch_i.dec_inst.imm;
            end

            default: ;
        endcase

        case (dispatch_i.funct)
            FUNCT_ADD: y = a + b;

            default: y = WORD_WIDTH'(0);
        endcase
    end

endmodule
