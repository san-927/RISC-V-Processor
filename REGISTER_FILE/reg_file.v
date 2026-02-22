`ifndef REG_FILE
`define REG_FILE

module register_file(
    input clk,
    input reset,
    input [4:0] read_reg1,
    input [4:0] read_reg2,
    input [4:0] write_reg,
    input [63:0] write_data,
    input reg_write_en,
    output [63:0] read_data1,
    output [63:0] read_data2
);

reg [63:0] registers [31:0];
integer i;

// Initialize registers
initial begin
    for (i = 0; i < 32; i = i + 1)
        registers[i] = 64'd0;
end

// Combinational Read
assign read_data1 = (read_reg1 == 5'd0) ? 64'd0 : registers[read_reg1];
assign read_data2 = (read_reg2 == 5'd0) ? 64'd0 : registers[read_reg2];

// Sequential Write + Reset
always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] <= 64'd0;
    end 
    else begin
        if (reg_write_en)
            registers[write_reg] <= write_data;

        //Hardwire x0 to zero
        registers[0] <= 64'd0;
    end
end

endmodule

`endif