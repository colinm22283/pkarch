module bw_mult_tb();

    parameter integer WIDTH = 32;
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
        .STAGES({ WIDTH { 1'b1 } }),
        // .STAGES('0),
        .EXTRA_SIZE(1)
    ) dut(
        .clk_i(clk),
        .nrst_i(nrst),

        .flush_i(1'b0),

        .valid_i(in_valid),
        .ready_o(in_ready),
        .a_unsigned_i(1'b0),
        .b_unsigned_i(1'b0),
        .a_i(in_data0),
        .b_i(in_data1),
        .extra_i('0),

        .valid_o(out_valid),
        .ready_i(out_ready),
        .y_o(out_data),
        .extra_o()
    );

    initial begin
        logic signed [WIDTH - 1:0] data [ITERS - 1:0] [1:0];

        in_valid  = '0;
        in_data0  = '0;
        in_data1  = '0;
        out_ready = '0;

        for (int i = 0; i < ITERS; i++) begin
            data[i][0] = WIDTH'($random);
            data[i][1] = WIDTH'($random);
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
                        wait(!clk);
                        if (in_ready) begin
                            wait(clk);

                            #1;

                            break;
                        end

                        wait(clk);
                        #1;
                    end

                    if ($random % 2 == 0) begin
                        in_valid = 1'b0;

                        wait(!clk);
                        wait(clk);
                        #1;

                        in_valid = 1'b1;
                    end
                end

                in_valid = 1'b0;
            end

            begin
                out_ready = 1'b1;

                for (int i = 0; i < ITERS; i++) begin
                    $display("Receiving %0d", i);

                    while (1) begin
                        wait(!clk);
                        #1;

                        if (out_valid) break;
                    end

                    if (data[i][0] * data[i][1] != out_data) begin
                        $display("Got %0d for %0d * %0d", out_data, data[i][0], data[i][1]);
                        $finish;
                    end

                    wait(clk);
                    #1;

                    if ($random %2 == 0) begin
                        out_ready = 1'b0;

                        wait(!clk);
                        wait(clk);
                        #1;

                        out_ready = 1'b1;
                    end
                end

                out_ready = 1'b0;
            end
        join

        $finish;
    end

    initial begin
        #10000000;
        $finish;
    end

endmodule

