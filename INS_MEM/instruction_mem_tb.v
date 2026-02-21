`timescale 1ns/1ps

module instruction_mem_tb;

reg [63:0] addr;
wire [31:0] instr;

integer errors = 0;

// Instantiate instruction memory
instruction_mem uut (
    .addr(addr),
    .instr(instr)
);

// Task to check instruction
task check_output;
    input [31:0] expected;
    begin
        #1; // allow combinational settle
        if (instr !== expected) begin
            $display("FAIL at addr %0d | Expected: %h | Got: %h",
                     addr, expected, instr);
            errors = errors + 1;
        end
        else begin
            $display("PASS at addr %0d | Instruction = %h",
                     addr, instr);
        end
    end
endtask

initial begin

    addr = 0;   check_output(32'h00500113);
    addr = 4;   check_output(32'h00A00193);
    addr = 8;   check_output(32'h003100B3);
    addr = 12;  check_output(32'h40310133);
    addr = 16;  check_output(32'h0031F233);
    addr = 20;  check_output(32'h0041F2B3);
    addr = 24;  check_output(32'h00416333);
    addr = 28;  check_output(32'h003163B3);
    addr = 32;  check_output(32'h0012B023);
    addr = 36;  check_output(32'h0002B503);
    addr = 40;  check_output(32'h0062BC23);
    addr = 44;  check_output(32'h0182B583);
    addr = 48;  check_output(32'h00520463);
    addr = 52;  check_output(32'h00000063);
    addr = 56;  check_output(32'h00A086B3);

    if (errors == 0)
        $display("\nALL INSTRUCTION MEMORY TESTS PASSED");
    else
        $display("\nTEST FAILED with %0d errors", errors);

    $finish;
end

endmodule