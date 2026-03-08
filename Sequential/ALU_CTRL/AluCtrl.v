`timescale 1ns/1ps

`ifndef AluCtrl
`define AluCtrl

module alu_control (ALUOp, funct3, funct7, ALUControl);
    input [1:0] ALUOp;
    input [2:0] funct3;
    input [6:0] funct7;
    output reg [3:0] ALUControl;
    wire f7bit = funct7[5];

    always @(*) begin
        case(ALUOp)

            2'b00: ALUControl = 4'b0010; // add

            2'b01: ALUControl = 4'b0110; // sub (beq)

            2'b10: begin
                case({f7bit, funct3})
                    4'b0000: ALUControl = 4'b0010; // add
                    4'b1000: ALUControl = 4'b0110; // sub
                    4'b0111: ALUControl = 4'b0000; // and
                    4'b0110: ALUControl = 4'b0001; // or
                    default: ALUControl = 4'b0010;
                endcase
            end
            default: ALUControl = 4'b0010;
        endcase
    end

endmodule

`endif