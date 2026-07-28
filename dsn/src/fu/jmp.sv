module jmp_m(
    input  logic clk_i,
    input  logic nrst_i,

    input  iq_commit_o_t dispatch_i,
    output iq_commit_i_t dispatch_o,

    input  commit_o_t commit_i,
    output commit_i_t commit_o
);

    logic run;
    logic mispred;
    spc_t offset;

    sword_t a, b;
    word_t a_u, b_u;

    always_comb begin
        a = dispatch_i.data.rs1_v;
        b = dispatch_i.data.rs2_v;
        a_u = a;
        b_u = b;

        case (dispatch_i.data.dec_inst.opcode)
            OPCODE_BRANCH: begin
                run    = 1;
                offset = $signed(dispatch_i.data.pc) + 4;

                case (dispatch_i.data.dec_inst.funct)
                    FUNCT_BEQ:  mispred = !(a == b);
                    FUNCT_BNE:  mispred = !(a != b);
                    FUNCT_BLT:  mispred = !(a < b);
                    FUNCT_BGE:  mispred = !(a >= b);
                    FUNCT_BLTU: mispred = !(a_u < b_u);
                    FUNCT_BGEU: mispred = !(a_u >= b_u);

                    default: mispred = 0;
                endcase
            end

            OPCODE_LINK: begin
                run     = 1;
                mispred = 0;
                offset = $signed(dispatch_i.data.pc) + 4;
            end

            OPCODE_LINKREG: begin
                run     = 1;
                mispred = 1;
                offset  = a + $signed(dispatch_i.data.dec_inst.imm);
            end

            default: begin
                run     = 0;
                mispred = 0;
                offset  = 0;
            end
        endcase

        dispatch_o.ready    = commit_i.ready && run;

        commit_o            = '0;

        commit_o.valid      = dispatch_i.valid && run;

        commit_o.rob_id     = dispatch_i.data.rob_id;

        commit_o.jmp        = 1;
        commit_o.mispred    = mispred;
        commit_o.jmp_target = offset;

        commit_o.isa_addr   = dispatch_i.data.isa_addr;
        commit_o.rd_a       = dispatch_i.data.dec_inst.rd_a;
        commit_o.rd         = dispatch_i.data.rd;
        commit_o.prev_rd    = dispatch_i.data.prev_rd;
        commit_o.value      = dispatch_i.data.pc + 4;
    end

endmodule

