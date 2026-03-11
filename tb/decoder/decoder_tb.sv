`timescale 1ns/100ps

`include "isa.svh"

module decoder_tb();

    inst_t inst;
    dec_inst_t decoded;

    decoder_m dut(
        .inst_i(inst),
        .decoded_o(decoded)
    );

    initial begin
        inst.opcode = 7'b0110011;

        #100;

        inst.opcode = 7'b1101111;

        #100;

        $finish;
    end

endmodule

