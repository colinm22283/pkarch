module bw_mult_tb();

    parameter integer WIDTH = 4;
    parameter integer ITERS = 1000;

    logic clk, nrst;

    clk_rst_m clk_rst(
        .clk_o(clk),
        .nrst_o(nrst)
    );

    logic in_valid, in_ready;
    logic signed [WIDTH - 1:0] in_data0;
    logic signed [WIDTH - 1:0] in_data1;

    logic out_valid, out_ready;
    logic signed [2 * WIDTH - 1:0] out_data;

    bw_mult_m #(
        .WIDTH(WIDTH),
        .STAGES('0)
    ) dut(
        .clk_i(clk),
        .nrst_i(nrst),

        .in_valid_i(in_valid),
        .in_ready_o(in_ready),
        .in_data0_i(in_data0),
        .in_data1_i(in_data1),

        .out_valid_o(out_valid),
        .out_ready_i(out_ready),
        .out_data_o(out_data)
    );

    initial begin
        logic signed [WIDTH - 1:0] data [ITERS - 1:0] [1:0];

        in_valid  = '0;
        in_data0  = '0;
        in_data1  = '0;
        out_ready = '0;

        for (int i = 0; i < ITERS; i++) begin
            // data[i][0] = WIDTH'($random);
            // data[i][1] = WIDTH'($random);

            data[i][0] = -4'sd1;
            data[i][1] = 4'd2;
        end

        clk_rst.RESET();

        fork
            begin
                in_valid = 1'b1;

                for (int i = 0; i < ITERS; i++) begin
                    $display("Sending %0d", i);

                    in_data0 = data[i][0];
                    in_data1 = data[i][1];

                    #1;

                    while (1) begin
                        @(posedge clk) if (in_ready) break;
                        #1;
                    end
                end

                in_valid = 1'b0;
            end

            begin
                out_ready = 1'b1;

                for (int i = 0; i < ITERS; i++) begin
                    $display("Receiving %0d", i);

                    while (1) begin
                        @(posedge clk) if (out_valid) break;
                        #1;
                    end

                    if (data[i][0] * data[i][1] != out_data) begin
                        $display("Got %0d for %0d * %0d", out_data, data[i][0], data[i][1]);
                        $finish;
                    end
                end

                out_ready = 1'b0;
            end
        join

        $finish;
    end

    initial begin
        #10000;
        $finish;
    end

endmodule

