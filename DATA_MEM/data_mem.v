`timescale 1ns/1ps
`ifndef data_mem
`define data_mem

module data_mem(clk, reset, address, write_data, MemRead, MemWrite, read_data);
input clk;
input reset;
input MemRead;
input MemWrite;
input [9:0] address;
input [63:0] write_data;
output reg [63:0] read_data;

reg [7:0] data_reg [0:1023]; //Big endian byte-addressable memory

integer i;
always @ (posedge clk or posedge reset) begin
    if(reset) begin     //Asynchronous reset
        for( i = 0; i<1024; i = i+1) begin
            data_reg[i] <= 8'b00000000;
        end
    end
    else if( MemWrite) begin
        data_reg[address]   <= write_data[63:56];
        data_reg[address+1] <= write_data[55:48];
        data_reg[address+2] <= write_data[47:40];
        data_reg[address+3] <= write_data[39:32];
        data_reg[address+4] <= write_data[31:24];
        data_reg[address+5] <= write_data[23:16];
        data_reg[address+6] <= write_data[15:8];
        data_reg[address+7] <= write_data[7:0];
    end
end

always @(*) begin
    if(reset) begin
        read_data = 64'b0;
    end
    else if( MemRead) begin
        read_data[63:56] = data_reg[address];
        read_data[55:48] = data_reg[address+1];
        read_data[47:40] = data_reg[address+2];
        read_data[39:32] = data_reg[address+3];
        read_data[31:24] = data_reg[address+4];
        read_data[23:16] = data_reg[address+5];
        read_data[15:8]  = data_reg[address+6];
        read_data[7:0]   = data_reg[address+7];
    end
    else begin
        read_data = 64'b0;
    end
end
endmodule



`endif 