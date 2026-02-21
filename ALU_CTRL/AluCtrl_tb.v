`timescale 1ns/1ps

module alu_control_tb;

reg [1:0] ALUOp;
reg [2:0] funct3;
reg [6:0] funct7;
wire [3:0] ALUControl;

alu_control uut (
    .ALUOp(ALUOp),
    .funct3(funct3),
    .funct7(funct7),
    .ALUControl(ALUControl)
);

initial begin

    $display("------ ALU CONTROL TEST ------");

    // ld / sd → ALUOp = 00 → ADD
    ALUOp = 2'b00; funct3 = 3'bxxx; funct7 = 7'bxxxxxxx;
    #10;
    $display("ALUOp=00 (load/store) → ALUControl = %b (Expected 0010)", ALUControl);

    // beq → ALUOp = 01 → SUB
    ALUOp = 2'b01; funct3 = 3'b000; funct7 = 7'b0000000;
    #10;
    $display("ALUOp=01 (beq) → ALUControl = %b (Expected 0110)", ALUControl);

    // ADD
    ALUOp = 2'b10; funct3 = 3'b000; funct7 = 7'b0000000;
    #10;
    $display("ADD → ALUControl = %b (Expected 0010)", ALUControl);

    // SUB
    ALUOp = 2'b10; funct3 = 3'b000; funct7 = 7'b0100000;
    #10;
    $display("SUB → ALUControl = %b (Expected 0110)", ALUControl);

    // AND
    ALUOp = 2'b10; funct3 = 3'b111; funct7 = 7'b0000000;
    #10;
    $display("AND → ALUControl = %b (Expected 0000)", ALUControl);

    // OR
    ALUOp = 2'b10; funct3 = 3'b110; funct7 = 7'b0000000;
    #10;
    $display("OR → ALUControl = %b (Expected 0001)", ALUControl);

    $display("------ TEST COMPLETE ------");
    $finish;

end

endmodule