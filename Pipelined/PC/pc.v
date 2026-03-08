module pc (
    input wire clk,
    input wire reset,
    input wire pc_write,
    input wire [63:0] pc_in,
    output reg [63:0] pc_out
);

always @(posedge clk or posedge reset) begin
    if (reset)
        pc_out <= 64'b0;      // Reset PC to 0
    else if(pc_write)
        pc_out <= pc_in;      // Load next PC every clock cycle
    else
        pc_out <= pc_out;
end

endmodule