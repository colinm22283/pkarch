`timescale 1ns/100ps

`include "isa.svh"

parameter CYCLES = 1000;

module prf_tb();

    wire clk, nrst;

    clk_rst_m clk_rst(
        .clk_o(clk),
        .nrst_o(nrst)
    );

    prf_port_i_t portsi [1:0];
    prf_port_o_t portso [1:0];

    prf_m dut(
        .clk_i(clk),
        .nrst_i(nrst),

        .prf_port_i({ portsi[1], portsi[0] }),
        .prf_port_o({ portso[1], portso[0] })
    );

    initial begin
        word_t data;

        clk_rst.RESET();

        $display("0 test");
        MAIN(0);

        #1000;

        $display("1 test");
        MAIN(1);

        #1000;

        $display("Success!");

        $finish;
    end

    task MAIN;
        input index;
    begin
        for (int i = 0; i < CYCLES; i++) begin
            prf_addr_t addr;
            word_t write_data;
            word_t read_data;

            addr = PRF_ADDR_WIDTH'({$random} % PRF_SIZE);
            write_data = {$random};

            PRF_WRITE(index, addr, write_data);
            PRF_READ(index, addr, read_data);

            if (write_data != read_data) begin
                $display("MISMATCH AT 0x%h", addr);
                $stop;
            end
        end
    end
    endtask

    task PRF_WRITE;
        input index;

        input prf_addr_t addr;
        input word_t data;
    begin
        wait(!clk);

        portsi[index].addr = addr;
        portsi[index].data = data;
        portsi[index].we   = 1;

        wait(clk);
        #1;

        portsi[index].we   = 0;
    end
    endtask

    task PRF_READ;
        input index;

        input prf_addr_t addr;
        output word_t data;
    begin
        wait(!clk);

        portsi[index].addr = addr;

        wait(clk);
        #1;

        data = portso[index].data;
    end
    endtask

endmodule

