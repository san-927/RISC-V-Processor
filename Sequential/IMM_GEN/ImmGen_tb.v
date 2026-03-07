`timescale 1ns/1ps

module ImmGen_tb;

reg [31:0] instr;
wire [63:0] imm_out;

ImmGen uut (
    .instr(instr),
    .imm_out(imm_out)
);

initial begin

    $display("---- I-TYPE TEST (addi x2, x0, -5) ----");
    // addi x2, x0, -5
    // imm = -5 = 12-bit 111111111011
    instr = 32'b111111111011_00000_000_00010_0010011;
    #10;
    $display("Immediate = %h", imm_out);

    $display("---- I-TYPE TEST (ld x1, 16(x0)) ----");
    // ld x1, 16(x0)
    instr = 32'b000000010000_00000_011_00001_0000011;
    #10;
    $display("Immediate = %h", imm_out);

    $display("---- S-TYPE TEST (sd x6, 24(x5)) ----");
    // imm = 24 = 000000011000
    instr = 32'b0000000_00110_00101_011_11000_0100011;
    #10;
    $display("Immediate = %h", imm_out);

    $display("---- B-TYPE TEST (beq x1, x2, 8) ----");
    // imm = 8
    // B-type encoding of 8
    instr = 32'b0000000_00010_00001_000_01000_1100011;
    #10;
    $display("Immediate = %h", imm_out);

    $finish;
end

endmodule