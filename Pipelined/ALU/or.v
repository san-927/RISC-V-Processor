`ifndef OR_V
`define OR_V

module or_64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] or_out,
    output zero_flag
);

    wire [63:0] or_stage;
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) 
            begin : or_gates
                or (or_out[i], a[i], b[i]);
            end
    endgenerate

     assign or_stage[0] = or_out[0];
    generate
        for (i = 1; i < 64; i = i + 1)
        begin : or_chain
           or(or_stage[i], or_stage[i-1], or_out[i]);
        end
    endgenerate
    not(zero_flag, or_stage[63]);
endmodule

`endif