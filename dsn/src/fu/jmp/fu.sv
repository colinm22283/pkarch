`include "fu.svh"
`include "commit.svh"
`include "prf.svh"

module jmp_fu_m(
    input wire clk_i,
    input wire nrst_i,

    input  fu_dispatch_i_t dispatch_i,
    output fu_dispatch_o_t dispatch_o,

    input  prf_rport_o_t [1:0] rport_i,
    output prf_rport_i_t [1:0] rport_o,

    input  commit_o_t commit_i,
    output commit_i_t commit_o
);

    logic run;
    logic read_ports_valid;

    sword_t a, b;
    word_t a_u, b_u;

    assign a   = rport_i[0].data;
    assign b   = rport_i[1].data;
    assign a_u = a;
    assign b_u = b;

    logic jump;
    logic relative;

    always_comb begin
        case (dispatch_i.dec_inst.opcode)
            OPCODE_BRANCH: begin
                run = 1;
                read_ports_valid = rport_i[0].valid && rport_i[1].valid;
                relative = 1;

                case (dispatch_i.dec_inst.funct)
                    FUNCT_BEQ:  jump = a == b;
                    FUNCT_BNE:  jump = a != b;
                    FUNCT_BLT:  jump = a < b;
                    FUNCT_BGE:  jump = a >= b;
                    FUNCT_BLTU: jump = a_u < b_u;
                    FUNCT_BGEU: jump = a_u >= b_u;

                    default: jump = 0;
                endcase
            end

            OPCODE_LINK: begin
                run = 1;
                read_ports_valid = 1;
                jump = 1;
                relative = 1;
            end

            OPCODE_LINKREG: begin
                run = 1;
                read_ports_valid = rport_i[0].valid;
                jump = 1;
                relative = 0;
            end

            default: begin
                run = 0;
                read_ports_valid = 0;
                jump = 0;
                relative = 0;
            end
        endcase
    end

endmodule
