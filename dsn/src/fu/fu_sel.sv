module fu_sel_m(
    dec_inst_t dec_inst_i,
    fu_select_t select_o
);

    case (dec_inst_i.opcode)
        OPCODE_REGALU, OPCODE_IMMALU, OPCODE_LUI, OPCODE_AUIPC: select_o = EU_ALU;
        OPCODE_BRANCH, OPCODE_LINK, OPCODE_LINKREG: select_o = EU_JMP;
        OPCODE_LOAD, OPCODE_STORE: select_o = EU_LSU;
        default: select_o = EU_NONE;
    endcase

endmodule
    
