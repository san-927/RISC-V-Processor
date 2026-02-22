`ifndef SRL_V
`define SRL_V
`include "ALU/sll.v"


module bshifter_right_64(
    input  [63:0] in,
    input  [5:0] shift_amt,   
    output [63:0] out,
    output zero_flag
);

wire [63:0] stage32, stage16, stage8, stage4, stage2, stage1, or_stage;

// STAGE 1 — SHIFT BY 32 (if shift_amt[5] = 1)
genvar i;
generate
    for (i = 0; i < 32; i = i + 1) begin
        mux2_1 m ( .a(in[i]), .b(in[i+32]), .sel(shift_amt[5]), .out(stage32[i]) );
    end
    for (i = 32; i < 64; i = i + 1) begin
        mux2_1 m ( .a(in[i]), .b(1'b0),       .sel(shift_amt[5]), .out(stage32[i]) );
    end
endgenerate


// STAGE 2 — SHIFT BY 16
generate
    for (i = 0; i < 48; i = i + 1) begin
        mux2_1 m ( .a(stage32[i]), .b(stage32[i+16]), .sel(shift_amt[4]), .out(stage16[i]) );
    end
    for (i = 48; i < 64; i = i + 1) begin
        mux2_1 m ( .a(stage32[i]), .b(1'b0),          .sel(shift_amt[4]), .out(stage16[i]) );
    end
endgenerate


// STAGE 3 — SHIFT BY 8
generate
    for (i = 0; i < 56; i = i + 1) begin
        mux2_1 m ( .a(stage16[i]), .b(stage16[i+8]), .sel(shift_amt[3]), .out(stage8[i]) );
    end
    for (i = 56; i < 64; i = i + 1) begin
        mux2_1 m ( .a(stage16[i]), .b(1'b0),.sel(shift_amt[3]), .out(stage8[i]) );
    end
endgenerate


// STAGE 4 — SHIFT BY 4
generate
    for (i = 0; i < 60; i = i + 1) begin
        mux2_1 m ( .a(stage8[i]), .b(stage8[i+4]), .sel(shift_amt[2]), .out(stage4[i]) );
    end
    for (i = 60; i < 64; i = i + 1) begin
        mux2_1 m ( .a(stage8[i]), .b(1'b0),.sel(shift_amt[2]), .out(stage4[i]) );
    end
endgenerate


// STAGE 5 — SHIFT BY 2
generate
    for (i = 0; i < 62; i = i + 1) begin
        mux2_1 m ( .a(stage4[i]), .b(stage4[i+2]), .sel(shift_amt[1]), .out(stage2[i]) );
    end
    for (i = 62; i < 64; i = i + 1) begin
        mux2_1 m ( .a(stage4[i]), .b(1'b0), .sel(shift_amt[1]), .out(stage2[i]) );
    end
endgenerate


// STAGE 6 — SHIFT BY 1
generate
    for (i = 0; i < 63; i = i + 1) begin
        mux2_1 m ( .a(stage2[i]), .b(stage2[i+1]), .sel(shift_amt[0]), .out(stage1[i]) );
    end
    mux2_1 m_last ( .a(stage2[63]), .b(1'b0), .sel(shift_amt[0]), .out(stage1[63]) );
endgenerate


assign out = stage1;

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
