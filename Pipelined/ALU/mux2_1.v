`ifndef MUX2_1_V
`define MUX2_1_V

module mux2_1(
    input a,
    input b,
    input sel, 
    output out
);

wire sel_not, out_a, out_b;
not(sel_not, sel);
and(out_a, a, sel_not);
and(out_b, b, sel);
or(out, out_a, out_b);

endmodule

`endif