`ifndef XOR_V
`define XOR_V

module xor_64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] xor_out,
    output zero_flag
);

    wire [63:0] or_stage;

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) 
            begin : xor_gates
                xor (xor_out[i], a[i], b[i]);
            end
    endgenerate

      assign or_stage[0] = xor_out[0];
    generate
        for (i = 1; i < 64; i = i + 1)
        begin : or_chain
           or(or_stage[i], or_stage[i-1], xor_out[i]);
        end
    endgenerate
    not(zero_flag, or_stage[63]);

endmodule

`endif