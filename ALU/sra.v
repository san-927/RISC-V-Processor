`ifndef SRA_V
`define SRA_V
`include "ALU/srl.v"



module bshifter_arith_right_64(
    input  [63:0] in,
    input  [5:0]  shift_amt,
    output [63:0] out,
    output        zero_flag
);

wire sign = in[63];

wire [63:0] s1, s2, s4, s8, s16, or_stage;


// STAGE 1 — shift by 1
genvar i;

// MSB always receives sign bit
mux2_1 s1_msb (.a(in[63]), .b(sign), .sel(shift_amt[0]), .out(s1[63]));

generate
    for (i = 62; i >= 0; i = i - 1) begin : stg1
        mux2_1 m (
            .a(in[i]),
            .b(in[i+1]),
            .sel(shift_amt[0]),
            .out(s1[i])
        );
    end
endgenerate



// STAGE 2 — shift by 2

// Top 2 bits replicate sign
mux2_1 s2_msb1 (.a(s1[63]), .b(sign), .sel(shift_amt[1]), .out(s2[63]));
mux2_1 s2_msb2 (.a(s1[62]), .b(sign), .sel(shift_amt[1]), .out(s2[62]));

generate
    for (i = 61; i >= 0; i = i - 1) begin : stg2
        mux2_1 m (
            .a(s1[i]),
            .b(s1[i+2]),
            .sel(shift_amt[1]),
            .out(s2[i])
        );
    end
endgenerate



// STAGE 3 — shift by 4

generate
    for (i = 63; i >= 60; i = i - 1) begin : stg3_pad
        mux2_1 m (.a(s2[i]), .b(sign), .sel(shift_amt[2]), .out(s4[i]));
    end
endgenerate

generate
    for (i = 59; i >= 0; i = i - 1) begin : stg3
        mux2_1 m (
            .a(s2[i]),
            .b(s2[i+4]),
            .sel(shift_amt[2]),
            .out(s4[i])
        );
    end
endgenerate



// STAGE 4 — shift by 8

generate
    for (i = 63; i >= 56; i = i - 1) begin : stg4_pad
        mux2_1 m (.a(s4[i]), .b(sign), .sel(shift_amt[3]), .out(s8[i]));
    end
endgenerate

generate
    for (i = 55; i >= 0; i = i - 1) begin : stg4
        mux2_1 m (
            .a(s4[i]),
            .b(s4[i+8]),
            .sel(shift_amt[3]),
            .out(s8[i])
        );
    end
endgenerate



// STAGE 5 — shift by 16

generate
    for (i = 63; i >= 48; i = i - 1) begin : stg5_pad
        mux2_1 m (.a(s8[i]), .b(sign), .sel(shift_amt[4]), .out(s16[i]));
    end
endgenerate

generate
    for (i = 47; i >= 0; i = i - 1) begin : stg5
        mux2_1 m (
            .a(s8[i]),
            .b(s8[i+16]),
            .sel(shift_amt[4]),
            .out(s16[i])
        );
    end
endgenerate



// STAGE 6 — shift by 32

generate
    for (i = 63; i >= 32; i = i - 1) begin : stg6_pad
        mux2_1 m (.a(s16[i]), .b(sign), .sel(shift_amt[5]), .out(out[i]));
    end
endgenerate

generate
    for (i = 31; i >= 0; i = i - 1) begin : stg6
        mux2_1 m (
            .a(s16[i]),
            .b(s16[i+32]),
            .sel(shift_amt[5]),
            .out(out[i])
        );
    end
endgenerate



// ZERO FLAG
or(or_stage[0], out[0], 1'b0);

generate
    for (i = 1; i < 64; i = i + 1) begin : or_reduce
        or(or_stage[i], or_stage[i-1], out[i]);
    end
endgenerate

not(zero_flag, or_stage[63]);

endmodule

`endif
