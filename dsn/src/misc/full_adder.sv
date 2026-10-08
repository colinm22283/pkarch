module full_adder_m(
    input  logic a_i,
    input  logic b_i,
    input  logic c_i,

    output logic y_o,
    output logic c_o
);

    assign { c_o, y_o } = a_i + b_i + c_i;

endmodule

