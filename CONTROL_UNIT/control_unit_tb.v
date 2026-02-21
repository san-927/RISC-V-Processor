`timescale 1ns/1ps

module control_unit_tb;
    reg [6:0] opcode;
    wire ALUSrc;
    wire MemtoReg;
    wire RegWrite;
    wire MemRead;
    wire MemWrite;
    wire Branch;
    wire [1:0] ALUOp;

    control_unit dut(
        .opcode(opcode),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUOp(ALUOp)
    );

    task check;
        input [6:0] exp_opcode;
        input expALUSrc;
        input expMemtoReg;
        input expRegWrite;
        input expMemRead;
        input expMemWrite;
        input expBranch;
        input [1:0] expALUOp;
        begin
            opcode = exp_opcode;
            #1;
            if (ALUSrc !== expALUSrc ||
                MemtoReg !== expMemtoReg ||
                RegWrite !== expRegWrite ||
                MemRead !== expMemRead ||
                MemWrite !== expMemWrite ||
                Branch !== expBranch ||
                ALUOp !== expALUOp) begin
                $display("FAIL opcode=%b ALUSrc=%b MemtoReg=%b RegWrite=%b MemRead=%b MemWrite=%b Branch=%b ALUOp=%b",
                         exp_opcode, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp);
                $display("Expected     ALUSrc=%b MemtoReg=%b RegWrite=%b MemRead=%b MemWrite=%b Branch=%b ALUOp=%b",
                         expALUSrc, expMemtoReg, expRegWrite, expMemRead, expMemWrite, expBranch, expALUOp);
                $fatal;
            end else begin
                $display("PASS opcode=%b", exp_opcode);
            end
        end
    endtask

    initial begin
        $display("------------Control Unit Tests------------");

        // R-format
        check(7'b0110011, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 2'b10);
        // load (ld)
        check(7'b0000011, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 2'b00);
        // store (sd)
        check(7'b0100011, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 2'b00);
        // branch (beq)
        check(7'b1100011, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b01);

        $finish;
    end
endmodule
