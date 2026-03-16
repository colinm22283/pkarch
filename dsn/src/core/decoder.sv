`timescale 1ns/100ps

`include "isa.svh"

module decoder_m(
    input inst_t inst_i,
    output dec_inst_t decoded_o
);

    enum reg [2:0] {
        TYPE_R,
        TYPE_I,
        TYPE_S,
        TYPE_B,
        TYPE_U,
        TYPE_J,
        TYPE_ERROR = 3'bxxx
    } inst_type;

    // inst_type
    always_comb begin
        case (inst_i.opcode)
            7'b0110011: inst_type = TYPE_R;

            7'b0010011, 7'b0000011: inst_type = TYPE_I;

            7'b0100011: inst_type = TYPE_S;

            7'b1100011: inst_type = TYPE_B;

            7'b1101111: inst_type = TYPE_J;

            7'b1100111: inst_type = TYPE_I;

            7'b0110111: inst_type = TYPE_U;
            7'b0010111: inst_type = TYPE_U;

            7'b1110011: inst_type = TYPE_I;

            default: inst_type = TYPE_ERROR;
        endcase
    end

    // regs
    always_comb begin
        case (inst_type)
            TYPE_R: begin
                decoded_o.rs1_a = 1'b1;
                decoded_o.rs2_a = 1'b1;
                decoded_o.rd_a  = 1'b1;
                decoded_o.rs1 = inst_i.t.r.rs1;
                decoded_o.rs2 = inst_i.t.r.rs2;
                decoded_o.rd = inst_i.t.r.rd;
            end

            TYPE_I: begin
                decoded_o.rs1_a = 1'b1;
                decoded_o.rs2_a = 1'b0;
                decoded_o.rd_a  = 1'b1;
                decoded_o.rs1   = inst_i.t.i.rs1;
                decoded_o.rs2   = REG_ERROR;
                decoded_o.rd    = inst_i.t.i.rd;
            end

            TYPE_S: begin
                decoded_o.rs1_a = 1'b1;
                decoded_o.rs2_a = 1'b1;
                decoded_o.rd_a  = 1'b0;
                decoded_o.rs1 = inst_i.t.s.rs1;
                decoded_o.rs2 = inst_i.t.s.rs2;
                decoded_o.rd  = REG_ERROR;
            end

            TYPE_B: begin
                decoded_o.rs1_a = 1'b1;
                decoded_o.rs2_a = 1'b1;
                decoded_o.rd_a  = 1'b0;
                decoded_o.rs1 = inst_i.t.b.rs1;
                decoded_o.rs2 = inst_i.t.b.rs2;
                decoded_o.rd  = REG_ERROR;
            end

            TYPE_U: begin
                decoded_o.rs1_a = 1'b0;
                decoded_o.rs2_a = 1'b0;
                decoded_o.rd_a  = 1'b1;
                decoded_o.rs1 = REG_ERROR;
                decoded_o.rs2 = REG_ERROR;
                decoded_o.rd  = inst_i.t.u.rd;
            end

            TYPE_J: begin
                decoded_o.rs1_a = 1'b0;
                decoded_o.rs2_a = 1'b0;
                decoded_o.rd_a  = 1'b1;
                decoded_o.rs1 = REG_ERROR;
                decoded_o.rs2 = REG_ERROR;
                decoded_o.rd  = inst_i.t.j.rd;
            end

            default: begin
                decoded_o.rs1_a = 1'bx;
                decoded_o.rs2_a = 1'bx;
                decoded_o.rd_a  = 1'bx;
                decoded_o.rs1 = REG_ERROR;
                decoded_o.rs2 = REG_ERROR;
                decoded_o.rd  = REG_ERROR;
            end
        endcase
    end

    // imm
    always_comb begin : IMM_COMB
        reg signed [11:0] imm_i;
        reg signed [11:0] imm_s;
        reg signed [11:0] imm_b;
        reg signed [19:0] imm_j;
        reg signed [19:0] imm_u;

        imm_i = $signed(inst_i.t.i.imm0);
        imm_s = $signed({ inst_i.t.s.imm1, inst_i.t.s.imm0 });
        imm_b = $signed({ inst_i.t.b.imm3, inst_i.t.b.imm2, inst_i.t.b.imm1, inst_i.t.b.imm0 });
        imm_u = $signed({ inst_i.t.u.imm0 });
        imm_j = $signed({ inst_i.t.j.imm3, inst_i.t.j.imm2, inst_i.t.j.imm1, inst_i.t.j.imm0 });

        case (inst_type)
            TYPE_R: decoded_o.imm = IMM_ERROR;
            TYPE_I: decoded_o.imm = 32'(imm_i);
            TYPE_S: decoded_o.imm = 32'(imm_s << 1);
            TYPE_B: decoded_o.imm = 32'(imm_b << 1);
            TYPE_U: decoded_o.imm = 32'(imm_u << 12);
            TYPE_J: decoded_o.imm = 32'(imm_j << 1);

            default: decoded_o.imm = IMM_ERROR;
        endcase
    end

    // funct
    always_comb begin
        case (inst_type)
            TYPE_R: decoded_o.funct = `FUNCT_CONCAT(inst_i.t.r.funct3, inst_i.t.r.funct7);
            TYPE_I: decoded_o.funct = `FUNCT_CONCAT(inst_i.t.i.funct3, 7'h00);
            TYPE_S: decoded_o.funct = `FUNCT_CONCAT(inst_i.t.s.funct3, 7'h00);
            TYPE_B: decoded_o.funct = `FUNCT_CONCAT(inst_i.t.b.funct3, 7'h00);
            TYPE_U: decoded_o.funct = `FUNCT_CONCAT(3'h0, 7'h00);
            TYPE_J: decoded_o.funct = `FUNCT_CONCAT(3'h0, 7'h00);

            default: decoded_o.funct = 10'hxxx;
        endcase
    end

    always_comb decoded_o.opcode = inst_i.opcode;

endmodule

