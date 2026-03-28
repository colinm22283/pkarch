`timescale 1ns/100ps

module res_station_m #(
) (
    input wire clk_i,
    input wire nrst_i,

    res_dispatch_i_t res_dispatch_i,
    res_dispatch_o_t res_dispatch_o,

    fu_test_o_t fu_test_i,
    fu_test_i_t fu_test_o,

    fu_dispatch_o_t fu_dispatch_i,
    fu_dispatch_i_t fu_dispatch_o
);

    

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
        end
        else begin
        end
    end

    always_comb begin
        for (int i = 0; i < DISPATCH_WIDTH; i++) begin
            fu_test_o[i].dec_inst = res_dispatch_i[i].dec_inst;

        end
    end

endmodule

