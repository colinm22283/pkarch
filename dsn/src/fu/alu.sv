module alu_m(
    input  logic clk_i,
    input  logic nrst_i,

    input  iq_commit_o_t dispatch_i,
    output iq_commit_i_t dispatch_o,

    input  commit_o_t commit_i,
    output commit_i_t commit_o
);

    sword_t a, b;
    word_t  a_u, b_u;
    sword_t y;

    always_comb begin
        a = dispatch_i.data.rs1_v;

        case (dispatch_i.data.dec_inst.opcode)
            OPCODE_REGALU: begin
                b = dispatch_i.data.rs2_v;
            end

            OPCODE_IMMALU, OPCODE_LUI, OPCODE_AUIPC: begin
                b = dispatch_i.data.dec_inst.imm;
            end

            default: begin
                b = 0;
            end
        endcase

        a_u = a;
        b_u = b;

        case (dispatch_i.data.dec_inst.opcode)
            OPCODE_REGALU, OPCODE_IMMALU: begin
                case (dispatch_i.data.dec_inst.funct)
                    FUNCT_ADD: y = a + b;

                    FUNCT_SUB: y = a - b;

                    FUNCT_XOR: y = a ^ b;

                    FUNCT_OR: y = a | b;

                    FUNCT_AND: y = a & b;

                    FUNCT_SLL: y = a << b;

                    FUNCT_SRL: y = a >> b;

                    FUNCT_SRA: y = a >>> b;

                    FUNCT_SLT: y = a < b ? WORD_WIDTH'(1'b1) : WORD_WIDTH'(1'b0);

                    FUNCT_SLTU: y = a_u < b_u ? WORD_WIDTH'(1'b1) : WORD_WIDTH'(1'b0);

                    default: y = '0;
                endcase
            end

            OPCODE_LUI: begin
                y = b << 12;
            end

            OPCODE_AUIPC: begin
                y = dispatch_i.data.pc + (b << 12);
            end

            default: y = '0;
        endcase

        dispatch_o.ready  = commit_i.ready;

        commit_o          = 0;

        commit_o.valid    = dispatch_i.valid;
        commit_o.rob_id   = dispatch_i.data.rob_id;
        commit_o.isa_addr = dispatch_i.data.isa_addr;
        commit_o.rd_a     = dispatch_i.data.dec_inst.rd_a;
        commit_o.rd       = dispatch_i.data.rd;
        commit_o.prev_rd  = dispatch_i.data.prev_rd;
        commit_o.value    = y;
    end


endmodule

