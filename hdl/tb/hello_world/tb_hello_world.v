module tb_hello_world();

    logger_m logger();

    reg test;

    initial begin
        test = 0;

        #30;

        test = 1;
    end

endmodule
