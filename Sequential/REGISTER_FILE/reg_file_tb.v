`timescale 1ns/1ps

module register_file_tb;

reg clk;
reg reset;
reg [4:0] read_reg1;
reg [4:0] read_reg2;
reg [4:0] write_reg;
reg [63:0] write_data;
reg reg_write_en;

wire [63:0] read_data1;
wire [63:0] read_data2;

integer errors = 0;

// Instantiate DUT
register_file uut (
    .clk(clk),
    .reset(reset),
    .read_reg1(read_reg1),
    .read_reg2(read_reg2),
    .write_reg(write_reg),
    .write_data(write_data),
    .reg_write_en(reg_write_en),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

// Clock generation (10ns period)
always #5 clk = ~clk;


// ================================
// Task to check read outputs
// ================================
task check_read;
    input [63:0] expected1;
    input [63:0] expected2;
    begin
        if (read_data1 !== expected1 || read_data2 !== expected2) begin
            $display("FAIL at time %0t | Expected: %h %h | Got: %h %h",
                      $time, expected1, expected2, read_data1, read_data2);
            errors = errors + 1;
        end
        else begin
            $display("PASS at time %0t | Read1: %h Read2: %h",
                      $time, read_data1, read_data2);
        end
    end
endtask


// ================================
// Test Sequence
// ================================
initial begin
    clk = 0;
    reset = 1;
    reg_write_en = 0;
    read_reg1 = 0;
    read_reg2 = 0;
    write_reg = 0;
    write_data = 0;

    // Apply reset
    #10;
    reset = 0;

    // --------------------------------------------------
    // Test 1: After reset all registers must be 0
    // --------------------------------------------------
    read_reg1 = 5'd1;
    read_reg2 = 5'd2;
    #1;
    check_read(64'd0, 64'd0);

    // --------------------------------------------------
    // Test 2: Write to register 5
    // --------------------------------------------------
    write_reg = 5'd5;
    write_data = 64'hAAAA_BBBB_CCCC_DDDD;
    reg_write_en = 1;

    #10;   // Wait for clock edge
    reg_write_en = 0;

    read_reg1 = 5'd5;
    read_reg2 = 5'd0;
    #1;
    check_read(64'hAAAA_BBBB_CCCC_DDDD, 64'd0);

    // --------------------------------------------------
    // Test 3: Write to register 10
    // --------------------------------------------------
    write_reg = 5'd10;
    write_data = 64'h1234_5678_9ABC_DEF0;
    reg_write_en = 1;

    #10;
    reg_write_en = 0;

    read_reg1 = 5'd10;
    read_reg2 = 5'd5;
    #1;
    check_read(64'h1234_5678_9ABC_DEF0,
               64'hAAAA_BBBB_CCCC_DDDD);

    // --------------------------------------------------
    // Test 4: Try writing to x0 (should NOT change)
    // --------------------------------------------------
    write_reg = 5'd0;
    write_data = 64'hFFFF_FFFF_FFFF_FFFF;
    reg_write_en = 1;

    #10;
    reg_write_en = 0;

    read_reg1 = 5'd0;
    read_reg2 = 5'd5;
    #1;
    check_read(64'd0, 64'hAAAA_BBBB_CCCC_DDDD);

    // --------------------------------------------------
    // Final result
    // --------------------------------------------------
    if (errors == 0)
        $display("\nALL TESTS PASSED");
    else
        $display("\nTEST FAILED with %0d errors", errors);

    $finish;
end

endmodule