module register_file(
    input clk,
    input reset,
    input [4:0] read_reg1,
    input [4:0] read_reg2,
    input [4:0] write_reg,
    input [63:0] write_data,
    input reg_write_en,
    output wire [63:0] read_data1,
    output wire [63:0] read_data2
);

reg [63:0] registers [31:0];
integer i;

// Initialize registers
initial begin
    for (i = 0; i < 32; i = i + 1) 
    begin
        registers[i] <= 64'b0;
    end
end

// Read data (combinational)
assign read_data1 = registers[read_reg1];
assign read_data2 = registers[read_reg2];
// Write data (sequential)
always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 32; i = i + 1) 
        begin
            registers[i] <= 64'b0;
        end
    end
    else if (reg_write_en && write_reg != 0) begin
        registers[write_reg] <= write_data;
    end
end

endmodule