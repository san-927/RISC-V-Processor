`timescale 1ns/1ps
`ifndef instruction_mem
`define instruction_mem

module instruction_mem #(
    parameter IMEM_SIZE = 4096
)(
    input  [63:0] addr,
    output reg [31:0] instr
);

reg [7:0] memory [0:IMEM_SIZE-1];
integer i;

// Load instructions from file
initial begin
    $readmemh("instructions.txt", memory);
end

always @(*) begin
    instr = { memory[addr], 
              memory[addr + 1], 
              memory[addr + 2], 
              memory[addr + 3] };
end

endmodule

`endif