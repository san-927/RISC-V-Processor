`ifndef SLT_V
`define SLT_V
`include "ALU/add_sub.v"

module set_less(
    input  [63:0] a,
    input  [63:0] b,
    output zero_flag,
    output [63:0] out
);

    wire carry_flag;
    wire overflow_flag;
    wire zero_flag_add;
    wire neg_flag;
    wire [63:0] alu_out;   
    add_sub_64 adder (
        .a(a),
        .b(b),
        .opcode(4'b1000),   
        .out(alu_out),      
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag),
        .zero_flag(zero_flag_add),
        .neg_flag(neg_flag)
    );

xor(out[0], neg_flag, overflow_flag);
assign out[63:1] = 63'b0;        
not(zero_flag, out[0]);

endmodule

`endif
