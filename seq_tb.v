`timescale 1ns/1ps
`include "processor.v"
module seq_tb;

    reg clk;
    reg reset;

    // Instantiate DUT
    processor dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always #5 clk = ~clk;

    // -------------------------
    // EXPECTED REGISTER FILE
    // -------------------------
    reg [63:0] expected_regs [0:31];
    integer i;

    initial begin
        $readmemh("register_file.txt", expected_regs);
    end


    // -------------------------
    // MAIN SIMULATION
    // -------------------------
    integer cycle_count;
    integer outfile;
    integer pass_flag;

    initial begin
        clk = 0;
        reset = 1;
        cycle_count = 0;
        pass_flag = 1;

        #20 reset = 0;

        // MAIN EXECUTION LOOP
        fork
            begin : RUN_LOOP
                while (1) begin
                    #10;
                    cycle_count = cycle_count + 1;

                    // HALT instruction detection
                    if (dut.instruction == 32'h00000063) begin
                        $display("HALT instruction encountered at cycle %0d", cycle_count);
                        disable RUN_LOOP;
                    end

                    // Timeout
                    if (cycle_count > 2000) begin
                        $display("TIMEOUT: No HALT instruction reached.");
                        disable RUN_LOOP;
                    end
                end
            end
        join

        // ============================
        //  END OF SIM → WRITE OUTPUT
        // ============================
        outfile = $fopen("register_file.txt", "w");

        for (i = 0; i < 32; i = i + 1) begin
            $fdisplay(outfile, "%016h", dut.reg_file_inst.registers[i]);
        end

        $fdisplay(outfile, "%0d", cycle_count);

        $fclose(outfile);

        // ============================
        //       PASS / FAIL CHECK
        // ============================
        for (i = 0; i < 32; i = i + 1) begin
            if (dut.reg_file_inst.registers[i] !== expected_regs[i]) begin
                $display("FAIL: x%0d mismatch. Expected=%h, Got=%h",
                         i, expected_regs[i], dut.reg_file_inst.registers[i]);
                pass_flag = 0;
            end
        end

        if (pass_flag) begin
            $display("***************************");
            $display("*******    PASS     *******");
            $display("***************************");
        end else begin
            $display("***************************");
            $display("*******    FAIL     *******");
            $display("***************************");
        end

        $finish;
    end

endmodule