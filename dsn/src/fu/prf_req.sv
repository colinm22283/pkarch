module prf_req_m(
    input logic clk_i,
    input logic nrst_i,

    input logic flush_i,

    input logic      req_i,
    input prf_addr_t addr_i,

    input  logic     accept_i,
    output logic     valid_o,
    output word_t    data_o,

    input  prf_rport_o_t rport_i,
    output prf_rport_i_t rport_o
);

    logic sent;

    logic hold;
    word_t held_data;

    always_ff @(posedge clk_i) begin
        if (!nrst_i) begin
            sent <= 0;
            hold <= 0;
        end
        else if (flush_i) begin
            sent <= 0;
            hold <= 0;
        end
        else begin
            if (accept_i && valid_o) begin
                sent <= 0;
                hold <= 0;
            end
            else if (rport_i.ack) begin
                hold      <= 1;
                held_data <= rport_i.data;
            end
            else if (!sent) sent <= req_i;
        end
    end

    always_comb begin
        rport_o.req  = req_i && !sent;
        rport_o.addr = addr_i;

        if (hold) begin
            valid_o = 1;
            data_o  = held_data;
        end
        else begin
            valid_o = rport_i.ack;
            data_o  = rport_i.data;
        end
    end

endmodule
