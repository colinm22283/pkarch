`include "fu/fu.svh"
`include "core/commit.svh"
`include "core/prf.svh"

module alu_fu_m(
    input wire clk_i,
    input wire nrst_i,

    input logic flush_i,

    input  fu_dispatch_i_t dispatch_i,
    output fu_dispatch_o_t dispatch_o,

    input  prf_rport_o_t [1:0] rport_i,
    output prf_rport_i_t [1:0] rport_o,

    input  commit_o_t commit_i,
    output commit_i_t commit_o
);

    logic [1:0]      rport_req;
    prf_addr_t [1:0] rport_addr;

    logic [1:0]  rport_valid;
    word_t [1:0] rport_data;

    sword_t a, b;
    word_t a_u, b_u;
    sword_t y;

    assign a_u = a;
    assign b_u = b;

    logic read_ports_valid;

    generate for (genvar i = 0; i < 2; i++) begin
        prf_req_m prf_req(
            .clk_i(clk_i),
            .nrst_i(nrst_i),

            .flush_i(flush_i),

            .req_i(rport_req[i]),
            .addr_i(rport_addr[i]),

            .accept_i(read_ports_valid),
            .valid_o(rport_valid[i]),
            .data_o(rport_data[i]),

            .rport_i(rport_i[i]),
            .rport_o(rport_o[i])
        );
    end endgenerate

    always_comb begin
        rport_addr[0] = dispatch_i.rs1;
        rport_addr[1] = dispatch_i.rs2;

        rport_req = 0;

        a = rport_data[0];

        case (dispatch_i.dec_inst.opcode)
            OPCODE_REGALU: begin
                read_ports_valid = rport_valid[0] && rport_valid[1];
                rport_req[0] = dispatch_i.valid;
                rport_req[1] = dispatch_i.valid;

                b = rport_i[1].data;
            end

            OPCODE_IMMALU: begin
                read_ports_valid = rport_valid[0];
                rport_req[0] = dispatch_i.valid;

                b = dispatch_i.dec_inst.imm;
            end

            OPCODE_LUI, OPCODE_AUIPC: begin
                read_ports_valid = 1;

                b = dispatch_i.dec_inst.imm;
            end

            default: begin
                read_ports_valid = 0;

                b = 0;
            end
        endcase

        case (dispatch_i.dec_inst.opcode)
            OPCODE_REGALU, OPCODE_IMMALU: begin
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
            end

            OPCODE_LUI: begin
                y = b << 12;
            end

            OPCODE_AUIPC: begin
                y = dispatch_i.pc + (b << 12);
            end

            default: y = WORD_WIDTH'(0);
        endcase

        dispatch_o.ready = commit_i.ready && read_ports_valid;

        commit_o = 0;

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
