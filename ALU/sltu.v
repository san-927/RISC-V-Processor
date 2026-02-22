`ifndef SLTU_V
`define SLTU_V
`include "ALU/slt.v"

module set_less_u(
    input  [63:0] a,
    input  [63:0] b,
    output [63:0] out,
    output zero_flag
);

    wire carry_flag;
    wire overflow_flag;
    wire zero_flag_add;
    wire neg_flag;
    wire [63:0] alu_out;   
    add_sub_64 adder (
        .a(a),
        .b(b),
        .opcode(4'b1001),   
        .out(alu_out),      
        .carry_flag(carry_flag),
        .overflow_flag(overflow_flag),
        .zero_flag(zero_flag_add),
        .neg_flag(neg_flag)
    );

wire nc;
not(nc, carry_flag);
assign out[63:1] = 63'b0;        
assign out[0] = nc;
assign zero_flag = carry_flag;

endmodule

`endif
