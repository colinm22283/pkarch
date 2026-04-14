`include "fu.svh"
`include "commit.svh"
`include "prf.svh"

module alu_fu_m(
    input wire clk_i,
    input wire nrst_i,

    input  fu_dispatch_i_t dispatch_i,
    output fu_dispatch_o_t dispatch_o,

    input  prf_rport_o_t [1:0] rport_i,
    output prf_rport_i_t [1:0] rport_o,

    input  commit_o_t commit_i,
    output commit_i_t commit_o
);

    sword_t a, b;
    word_t a_u, b_u;
    sword_t y;

    assign a_u = a;
    assign b_u = b;

    logic read_ports_valid;

    always_comb begin
        rport_o[0].addr = dispatch_i.rs1;
        rport_o[1].addr = dispatch_i.rs2;

        a = rport_i[0].data;

        case (dispatch_i.dec_inst.opcode)
            7'b0110011: begin
                read_ports_valid = rport_i[0].valid && rport_i[1].valid;

                b = rport_i[1].data;
            end

            7'b0010011: begin
                read_ports_valid = rport_i[0].valid;

                b = dispatch_i.dec_inst.imm;
            end

            default: begin
                read_ports_valid = 0;

                b = 0;
            end
        endcase

        case (dispatch_i.dec_inst.funct)
            FUNCT_ADD: y = a + b;

            FUNCT_SUB: y = a - b;

            FUNCT_XOR: y = a ^ b;

            FUNCT_OR: y = a | b;

            FUNCT_AND: y = a & b;

            FUNCT_SLL: y = a >> b;

            FUNCT_SRL: y = a << b;

            FUNCT_SRA: y = a >>> b;

            FUNCT_SLT: y = a < b ? WORD_WIDTH'(1'b1) : WORD_WIDTH'(1'b0);

            FUNCT_SLTU: y = a_u < b_u ? WORD_WIDTH'(1'b1) : WORD_WIDTH'(1'b0);

            default: y = WORD_WIDTH'(0);
        endcase

        dispatch_o.ready = commit_i.ready && read_ports_valid;

        commit_o.valid    = dispatch_i.valid && read_ports_valid;
        commit_o.rob_id   = dispatch_i.rob_id;
        commit_o.isa_addr = dispatch_i.isa_addr;
        commit_o.rd_a     = dispatch_i.dec_inst.rd_a;
        commit_o.rd       = dispatch_i.rd;
        commit_o.prev_rd  = dispatch_i.prev_rd;
        commit_o.value    = y;
    end

    wire running;
    assign running = commit_o.valid;

endmodule
