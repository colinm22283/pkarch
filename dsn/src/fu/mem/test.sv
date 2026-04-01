`timescale 1ns/100ps

`include "fu.svh"

module alu_test_m(
    input  fu_test_i_t test_i,
    output fu_test_o_t test_o
);

    always_comb begin
        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            case (test_i[i].dec_inst.opcode)
                OPCODE_REGALU, OPCODE_IMMALU: test_o[i].accept = 1'b1;

                default: test_o[i].accept = 1'b0;
            endcase
        end
    end

endmodule

