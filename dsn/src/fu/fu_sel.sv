`include "fu/execution_unit.svh"

module fu_sel_m(
    input  dec_inst_t dec_inst_i,
    output fu_select_t select_o
);

    always_comb begin
        case (dec_inst_i.opcode)
            OPCODE_REGALU, OPCODE_IMMALU, OPCODE_LUI, OPCODE_AUIPC: select_o = FU_ALU;
            OPCODE_BRANCH, OPCODE_LINK, OPCODE_LINKREG: select_o = FU_JMP;
            OPCODE_LOAD, OPCODE_STORE: select_o = FU_LSU;
            default: select_o = FU_NONE;
        endcase
    end

endmodule
    
