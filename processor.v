`timescale 1ns/1ps

`include "./ALU/alu.v"
`include "./ALU_CTRL/AluCtrl.v"
`include "./DATA_MEM/data_mem.v"
`include "./INS_MEM/instruction_mem.v"
`include "./REGISTER_FILE/reg_file.v"
`include "./CONTROL_UNIT/control_unit.v"
`include "./IMM_GEN/ImmGen.v"
`include "./PC/pc.v"

module processor(
    input clk,
    input reset
);

    wire [63:0] pc_in;
    wire [63:0] pc_out;
    wire [31:0] instruction;

    pc program_counter(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    instruction_mem imem(
        .addr(pc_out),
        .instr(instruction)
    );


    wire [63:0] pc_increment_normal;
    wire   pc_add_zero;
    add_sub_64 add_sub_unit(
        .a(pc_out),
        .b(64'd4),
        .opcode(4'b0000),
        .out(pc_increment_normal),
        .zero_flag(pc_add_zero)
    );

    // Control signals
    wire Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite;
    wire [1:0] ALUOP;

    control_unit control_unit_inst(
        .opcode(instruction[6:0]),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ALUOp(ALUOP)
    );


    // Register file
    wire [4:0] rs1, rs2, rd;
    wire [63:0] reg_data1, reg_data2, reg_write_data;

    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd = instruction[11:7];
    register_file reg_file_inst(
        .clk(clk),
        .reset(reset),
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(rd),
        .write_data(reg_write_data),
        .reg_write_en(RegWrite),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

    // Immediate generator
    wire [63:0] imm_gen_out;
    ImmGen imm_gen_inst(
        .instr(instruction),
        .imm_out(imm_gen_out)
    );

    // ALU control
    // ALU control signal generation is based on the way given in Patterson Hennessy book, which uses both ALUOP and funct fields to determine the ALU operation.
    // In the project documentation, it is mentioned that ALU control signal is genetrated based on instr[30] and funct3 
    // However for the sake of completeness and correctness we have implemented the ALU control signal to consider the whole funct7 param aswell.

    
    wire [3:0] alu_control_signal;
    alu_control alu_ctrl_inst(
        .ALUOp(ALUOP),
        .funct7(instruction[31:25]),
        .funct3(instruction[14:12]),
        .ALUControl(alu_control_signal)
    );


    // ALU Wire assignment
    wire [63:0] alu_input2;
    wire alu_zero_flag;

    assign alu_input2 = (ALUSrc) ? imm_gen_out : reg_data2; // Multiplexing between register data and immediate value based on ALUSrc signal
    wire [63:0] alu_result;
    alu_64_bit alu_inst(
        .a(reg_data1),
        .b(alu_input2),
        .opcode(alu_control_signal),
        .result(alu_result),
        .zero_flag(alu_zero_flag) 
    );

    //Shift Left Logical for calculating branch target address
    wire [63:0] imm_gen_out_shifted;
    assign imm_gen_out_shifted [63:1] = imm_gen_out [62:0];
    assign imm_gen_out_shifted [0] = 1'b0; 

    // Branch target address calculation
    wire [63:0] branch_target_address;
    wire  branch_add_zero;
    add_sub_64 branch_adder(
        .a(pc_out),
        .b(imm_gen_out_shifted),
        .opcode(4'b0000), // Addition
        .out(branch_target_address),
        .zero_flag(branch_add_zero)
    ); 
    
    // Next PC logic
    wire branch_taken;
    and(branch_taken, Branch, alu_zero_flag); // Branch is taken if Branch control signal is high and ALU zero flag is set
    assign pc_in = (branch_taken) ? branch_target_address : pc_increment_normal; // If branch is taken, next PC is the branch target address, otherwise it's the incremented PC


    // Data memory
    wire [63:0] mem_read_data;
    data_mem data_mem_inst(
        .clk(clk),
        .reset(reset),
        .address(alu_result[9:0]), // Using lower 10 bits of ALU result as address for data memory
        .write_data(reg_data2), // Data to write comes from the second register operand
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .read_data(mem_read_data)
    );

    // Write-back logic
    assign reg_write_data = (MemtoReg) ? mem_read_data : alu_result; // If MemtoReg is high, write back data from memory, otherwise write back ALU result


    
endmodule