`include "fu/execution_unit.svh"
`include "isa.svh"

module fu_sel_m(
    input  dec_inst_t dec_inst_i,
    output fu_select_t select_o
);

    always_comb begin
        case (dec_inst_i.opcode)
            OPCODE_REGALU, OPCODE_IMMALU, OPCODE_LUI, OPCODE_AUIPC: begin
                case (dec_inst_i.funct)
                    FUNCT_MUL, FUNCT_MULH, FUNCT_MULSU, FUNCT_MULHU: select_o = FU_INTMUL;
                    default: select_o = FU_ALU;
                endcase
            end
            OPCODE_BRANCH, OPCODE_LINK, OPCODE_LINKREG: select_o = FU_JMP;
            OPCODE_LOAD, OPCODE_STORE: select_o = FU_LSU;
            default: select_o = FU_NONE;
        endcase
    end

endmodule
    
