`timescale 1ns/1ps

module pc_tb;

reg clk;
reg reset;
reg [63:0] pc_in;
wire [63:0] pc_out;

integer errors = 0;

// Instantiate PC
pc uut (
    .clk(clk),
    .reset(reset),
    .pc_in(pc_in),
    .pc_out(pc_out)
);

// Clock generation (10ns period)
always #5 clk = ~clk;

// Task to check output
task check_output;
    input [63:0] expected;
    begin
        if (pc_out !== expected) begin
            $display("FAIL at time %0t | Expected: %h | Got: %h",
                     $time, expected, pc_out);
            errors = errors + 1;
        end
        else begin
            $display("PASS at time %0t | PC = %h",
                     $time, pc_out);
        end
    end
endtask

initial begin
    clk = 0;
    reset = 1;
    pc_in = 0;

    // Apply reset
    #10;
    check_output(64'd0);   // PC should be 0

    // Release reset
    reset = 0;
    pc_in = 64'd4;

    #10;  // wait for clock edge
    check_output(64'd4);

    pc_in = 64'd8;
    #10;
    check_output(64'd8);

    pc_in = 64'd12;
    #10;
    check_output(64'd12);

    // Simulate branch jump
    pc_in = 64'd100;
    #10;
    check_output(64'd100);

    // Final result
    if (errors == 0)
        $display("\nALL TESTS PASSED");
    else
        $display("\nTEST FAILED with %0d errors", errors);

    $finish;
end

endmodule