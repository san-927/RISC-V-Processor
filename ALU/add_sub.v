`ifndef ADD_SUB_V
`define ADD_SUB_V
`include "xor.v"

module full_adder(
    input a,
    input b,
    input cin,
    output sum,
    output cout
);

    wire s1, ab, cin_s1;;
    xor(s1, a, b);
    xor(sum, s1, cin);
    and(ab, a, b);
    and(cin_s1, cin, s1);
    or(cout, ab, cin_s1);

endmodule

module add_sub_64(
    input [63:0] a,
    input [63:0] b,
    input [3:0] opcode,
    output [63:0] out,
    output carry_flag,
    output overflow_flag,
    output zero_flag,
    output neg_flag
);

    wire [63:0] bf, or_stage;

    xor xor1 [63:0] (bf, b, {64{opcode[3]}});
    wire [64:0]carry;
    assign carry[0] = opcode[3]; 
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) 
        begin : full_adders
            full_adder fa (
                .a(a[i]),
                .b(bf[i]),
                .cin(carry[i]),
                .sum(out[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    generate
        for (i = 1; i < 64; i = i + 1)
        begin : or_chain
            or(or_stage[i], or_stage[i-1], out[i]);
        end
    endgenerate

    assign neg_flag = out[63];
    assign carry_flag = carry[64];
    xor(overflow_flag, carry[63], carry[64]);
    not(zero_flag, or_stage[63]);

endmodule

`endif