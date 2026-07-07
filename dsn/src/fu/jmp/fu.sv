`include "fu/fu.svh"
`include "core/commit.svh"
`include "core/prf.svh"

module jmp_fu_m(
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

    logic run;
    logic read_ports_valid;

    sword_t a, b;
    word_t a_u, b_u;

    assign a   = rport_i[0].data;
    assign b   = rport_i[1].data;
    assign a_u = a;
    assign b_u = b;

    logic jump;
    spc_t  offset;

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
        rport_req = 0;

        case (dispatch_i.dec_inst.opcode)
            OPCODE_BRANCH: begin
                run = 1;
                read_ports_valid = rport_valid[0] && rport_valid[1];
                // offset = dispatch_i.pc + $signed(dispatch_i.dec_inst.imm);
                offset = $signed(dispatch_i.pc) + 4;

                rport_req[0] = dispatch_i.valid;
                rport_req[1] = dispatch_i.valid;

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
                // offset = $signed(dispatch_i.pc) + $signed(dispatch_i.dec_inst.imm);
                offset = $signed(dispatch_i.pc) + 4;
            end

            OPCODE_LINKREG: begin
                run = 1;
                read_ports_valid = rport_valid[0];
                jump = 1;
                offset = $signed(rport_data[0]) + $signed(dispatch_i.dec_inst.imm);

                rport_req[0] = dispatch_i.valid;
            end

            default: begin
                run = 0;
                read_ports_valid = 0;
                jump = 0;
                offset = 0;
            end
        endcase
    end

    always_comb begin
        rport_addr[0] = dispatch_i.rs1;
        rport_addr[1] = dispatch_i.rs2;

        dispatch_o.ready = commit_i.ready && read_ports_valid;

        commit_o = 0;
        
        commit_o.valid = run && read_ports_valid;

        commit_o.rob_id = dispatch_i.rob_id;

        commit_o.jmp = 1;
        commit_o.mispred = !jump;
        commit_o.jmp_target = offset;

        commit_o.isa_addr = dispatch_i.isa_addr;
        commit_o.rd_a     = dispatch_i.dec_inst.rd_a;
        commit_o.rd       = dispatch_i.rd;
        commit_o.prev_rd  = dispatch_i.prev_rd;
        commit_o.value    = dispatch_i.pc + 4;
    end

    wire running;
    assign running = commit_o.valid;

endmodule
