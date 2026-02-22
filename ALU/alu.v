`include "ALU/and.v"
`include "ALU/or.v"
`include "ALU/xor.v"
`include "ALU/add_sub.v"
`include "ALU/sll.v"
`include "ALU/srl.v"
`include "ALU/sra.v"
`include "ALU/sltu.v"


module alu_64_bit(
    input  [63:0] a,
    input  [63:0] b,
    input  [3:0] opcode,
    output reg [63:0] result,
    output reg cout,
    output reg carry_flag,
    output reg overflow_flag,
    output reg zero_flag
);

    // Internal wires for outputs of each module
    wire [63:0] and_out, or_out, xor_out;
    wire [63:0] sll_out, srl_out, sra_out;
    wire [63:0] slt_out, sltu_out;
    wire [63:0] addsub_out;
    wire addsub_cout, addsub_overflow;
    wire and_zero, or_zero, xor_zero;
    wire sll_zero, srl_zero, sra_zero;
    wire slt_zero, sltu_zero;
    wire addsub_zero, neg_flag;

    
    and_64 u_and   (.a(a), .b(b), .and_out(and_out), .zero_flag(and_zero));
    or_64  u_or    (.a(a), .b(b), .or_out(or_out), .zero_flag(or_zero));
    xor_64 u_xor   (.a(a), .b(b), .xor_out(xor_out), .zero_flag(xor_zero));

    // Translate new ALU opcode to legacy encoding used by this ALU
    reg [3:0] opcode_old;

    always @(*) begin
        case (opcode)
            4'b0000: opcode_old = 4'b0111; // AND
            4'b0001: opcode_old = 4'b0110; // OR
            4'b0010: opcode_old = 4'b0000; // ADD
            4'b0011: opcode_old = 4'b0001; // SLL
            4'b0100: opcode_old = 4'b0010; // SLT
            4'b0101: opcode_old = 4'b0011; // SLTU
            4'b0110: opcode_old = 4'b1000; // SUB
            4'b0111: opcode_old = 4'b0100; // XOR
            4'b1000: opcode_old = 4'b0101; // SRL
            4'b1010: opcode_old = 4'b1101; // SRA
            default: opcode_old = 4'b0000; // default to ADD
        endcase
    end

    add_sub_64 u_addsub(
        .a(a),
        .b(b),
        .opcode(opcode_old),
        .out(addsub_out),
        .carry_flag(addsub_cout),
        .overflow_flag(addsub_overflow),
        .zero_flag(addsub_zero),
        .neg_flag(neg_flag)
    );

    bshifter_left_64  u_sll  (.in(a), .shift_amt(b[5:0]), .out(sll_out), .zero_flag(sll_zero));
    bshifter_right_64  u_srl  (.in(a), .shift_amt(b[5:0]), .out(srl_out), .zero_flag(srl_zero));
    bshifter_arith_right_64  u_sra  (.in(a), .shift_amt(b[5:0]), .out(sra_out), .zero_flag(sra_zero));

    set_less  u_slt  (.a(a), .b(b), .out(slt_out), .zero_flag(slt_zero));
    set_less_u u_sltu (.a(a), .b(b), .out(sltu_out), .zero_flag(sltu_zero));

    
    always @(*) begin
        zero_flag = (result == 64'd0);
    end

    
    always @(*) begin
        // Default values
        cout = 0;
        carry_flag = 0;
        overflow_flag = 0;
        result = 64'd0;

        case (opcode_old)
            // ADD
            4'b0000: begin
                result = addsub_out;
                cout = addsub_cout;
                carry_flag = addsub_cout;
                overflow_flag = addsub_overflow;
            end

            // SLL
            4'b0001: begin
                result = sll_out;
            end

            // SLT
            4'b0010: begin
                result = slt_out;
            end

            // SLTU
            4'b0011: begin
                result = sltu_out;
            end

            // XOR
            4'b0100: begin
                result = xor_out;
            end

            // SRL
            4'b0101: begin
                result = srl_out;
            end

            // OR
            4'b0110: begin
                result = or_out;
            end

            // AND
            4'b0111: begin
                result = and_out;
            end

            // SUB
            4'b1000: begin
                result = addsub_out;
                cout = addsub_cout;
                carry_flag = addsub_cout;
                overflow_flag = addsub_overflow;
            end

            // SRA
            4'b1101: begin
                result = sra_out;
            end

            // DEFAULT → 0
            default: begin
                result = 64'd0;
            end
        endcase
    end

endmodule
