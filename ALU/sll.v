`ifndef SLL_V
`define SLL_V
`include "ALU/mux2_1.v"


module bshifter_left_64(
    input  [63:0] in,
    input  [5:0] shift_amt,
    output [63:0] out,
    output zero_flag

);

wire [63:0] s1, s2, s4, s8, s16, or_stage;

// STAGE 1 — shift by 1
// out[i] = in[i-1] when shift_amt[0] = 1
genvar i;
generate
    for (i = 63; i > 0; i = i - 1) begin : sh1
        mux2_1 m (
            .a(in[i]),        // no shift
            .b(in[i-1]),      // shift left by 1
            .sel(shift_amt[0]),
            .out(s1[i])
        );
    end
endgenerate

// LSB always becomes 0 if shifting by 1
mux2_1 m1_0 (
    .a(in[0]),
    .b(1'b0),
    .sel(shift_amt[0]),
    .out(s1[0])
);


// STAGE 2 — shift by 2
generate
    for (i = 63; i > 1; i = i - 1) begin : sh2
        mux2_1 m (
            .a(s1[i]),
            .b(s1[i-2]),
            .sel(shift_amt[1]),
            .out(s2[i])
        );
    end
endgenerate

mux2_1 m2_1 (.a(s1[1]), .b(1'b0), .sel(shift_amt[1]), .out(s2[1]));
mux2_1 m2_0 (.a(s1[0]), .b(1'b0), .sel(shift_amt[1]), .out(s2[0]));


// STAGE 3 — shift by 4
generate
    for (i = 63; i > 3; i = i - 1) begin : sh4
        mux2_1 m (
            .a(s2[i]),
            .b(s2[i-4]),
            .sel(shift_amt[2]),
            .out(s4[i])
        );
    end
endgenerate

generate
    for (i = 3; i >= 0; i = i - 1) begin : sh4_pad
        mux2_1 m (.a(s2[i]), .b(1'b0), .sel(shift_amt[2]), .out(s4[i]));
    end
endgenerate


// STAGE 4 — shift by 8
generate
    for (i = 63; i > 7; i = i - 1) begin : sh8
        mux2_1 m (
            .a(s4[i]),
            .b(s4[i-8]),
            .sel(shift_amt[3]),
            .out(s8[i])
        );
    end
endgenerate

generate
    for (i = 7; i >= 0; i = i - 1) begin : sh8_pad
        mux2_1 m (.a(s4[i]), .b(1'b0), .sel(shift_amt[3]), .out(s8[i]));
    end
endgenerate


// STAGE 5 — shift by 16
generate
    for (i = 63; i > 15; i = i - 1) begin : sh16
        mux2_1 m (
            .a(s8[i]),
            .b(s8[i-16]),
            .sel(shift_amt[4]),
            .out(s16[i])
        );
    end
endgenerate

generate
    for (i = 15; i >= 0; i = i - 1) begin : sh16_pad
        mux2_1 m (.a(s8[i]), .b(1'b0), .sel(shift_amt[4]), .out(s16[i]));
    end
endgenerate


// STAGE 6 — shift by 32
generate
    for (i = 63; i > 31; i = i - 1) begin : sh32
        mux2_1 m (
            .a(s16[i]),
            .b(s16[i-32]),
            .sel(shift_amt[5]),
            .out(out[i])
        );
    end
endgenerate

generate
    for (i = 31; i >= 0; i = i - 1) begin : sh32_pad
        mux2_1 m (.a(s16[i]), .b(1'b0), .sel(shift_amt[5]), .out(out[i]));
    end
endgenerate

assign or_stage[0] = out[0];
 generate
        for (i = 1; i < 64; i = i + 1)
        begin : or_chain
            or(or_stage[i], or_stage[i-1], out[i]);
        end
endgenerate

not(zero_flag, or_stage[63]);

endmodule

`endif
