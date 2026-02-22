`timescale 1ns / 1ps
`include "data_mem.v"

module data_mem_tb;

    reg clk;
    reg reset;
    reg MemRead;
    reg MemWrite;
    reg [9:0] address;
    reg [63:0] write_data;
    wire [63:0] read_data;


    data_mem uut(
        .clk(clk),
        .reset(reset),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );


    task check;
        input [9:0] exp_address;
        input [63:0] exp_write_data;
        input exp_MemRead;
        input exp_MemWrite;
        input [63:0] exp_read_data;
        begin
            address = exp_address;
            write_data = exp_write_data;
            MemRead = exp_MemRead;
            MemWrite = exp_MemWrite;
            #10; // Wait for the operation to complete

            if (read_data !== exp_read_data) begin
                $display("FAIL address=%b write_data=%h MemRead=%b MemWrite=%b read_data=%h",
                         exp_address, exp_write_data, exp_MemRead, exp_MemWrite, read_data);
                $display("Expected read_data=%h", exp_read_data);
                $fatal;
            end else begin
                $display("PASS address=%b write_data=%h MemRead=%b MemWrite=%b read_data=%h",
                         exp_address, exp_write_data, exp_MemRead, exp_MemWrite, read_data);
            end
        end
    endtask


    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    initial begin
        reset = 1;
        #2;
        reset = 0;
        $display("------------Data Memory Tests------------");



        
        // Test 1: Write and read back a value
        check(10'b0000000000, 64'hDEADBEEFCAFEBABE, 1'b0, 1'b1, 64'h0000000000000000); // Write operation, read_data should be 0


        // Test 2: Check reading from the address we just wrote to (should return the value we wrote)
        check(10'b0000000000, 64'h0, 1'b1, 1'b0, 64'hDEADBEEFCAFEBABE); // Read operation, should return the value we just wrote

        // Test 3: Check that reading from an unwritten address returns 0  (Make sure to not use the middle bytes of the previous double word)
        check(10'b0000001000, 64'h0, 1'b1, 1'b0, 64'h0000000000000000); // Read from an unwritten address, should return 0

        //Test 4: Check that writing to a different address does not affect the previous address
        check(10'b0000001000, 64'h1234567890ABCDEF, 1'b0, 1'b1, 64'h0000000000000000); // Write to a different address
        check(10'b0000000000, 64'h0, 1'b1, 1'b0, 64'hDEADBEEFCAFEBABE); // Read from the first address again, should still return the original value
        check(10'b0000001000, 64'h0, 1'b1, 1'b0, 64'h1234567890ABCDEF); // Read from the second address, should return the new value

        //Test 5: Check that write data input does not affect read data when MemWrite is not asserted
        check(10'b0000000000, 64'hFFFFFFFFFFFFFFFF, 1'b1, 1'b0, 64'hDEADBEEFCAFEBABE); // Set write_data to all 1s but only assert MemRead, should return the original value


            

        $display("All tests passed!");
        $finish;
    end
endmodule