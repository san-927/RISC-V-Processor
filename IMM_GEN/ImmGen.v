`timescale 1ns/1ps

`ifndef ImmGen
`define ImmGen

module ImmGen (instr, imm_out);
    input [31:0] instr;
    output reg [63:0] imm_out;
    wire [6:0] opcode = instr[6:0];

    always @(*) begin
        case(opcode)

            7'b0010011:  // I-type
                imm_out = {{52{instr[31]}}, instr[31:20]};

            7'b0000011:  // I-type
                imm_out = {{52{instr[31]}}, instr[31:20]};

            7'b0100011: // S-type
                imm_out = {{52{instr[31]}}, instr[31:25], instr[11:7]};

            7'b1100011: // B-type (includes implicit low bit 0)
                imm_out = {{51{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

            default:
                imm_out = 64'd0;
        endcase
    end
endmodule

`endif