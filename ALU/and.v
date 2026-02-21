`ifndef AND_V
`define AND_V

module and_64(
    input [63:0] a,
    input [63:0] b,
    output zero_flag,
    output [63:0] and_out
);
    wire [63:0] or_stage;
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) 
            begin : and_gates
                and (and_out[i], a[i], b[i]);
            end
    endgenerate
    
    assign or_stage[0] = and_out[0];
    generate
        for (i = 1; i < 64; i = i + 1)
        begin : or_chain
           or(or_stage[i], or_stage[i-1], and_out[i]);
        end
    endgenerate
    not(zero_flag, or_stage[63]);

endmodule

`endif