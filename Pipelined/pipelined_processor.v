`timescale 1ns/1ps

`include "ALU/alu.v"
`include "ALU_CTRL/AluCtrl.v"
`include "CONTROL_UNIT/control_unit.v"
`include "DATA_MEM/data_mem.v"
`include "IMM_GEN/ImmGen.v"
`include "INS_MEM/instruction_mem.v"
`include "PC/pc.v"
`include "REGISTER_FILE/reg_file.v"


module pipelined_processor(
    input clk,
    input rst
);





//  Instruction Fetch Stage

wire pc_mux_0;
wire [63:0] pc_out;
wire [63:0] pc_in;
wire [31:0] instruction;

pc pc_inst (
    .clk(clk),
    .rst(rst),
    .pc_in(pc_in), 
    .pc_out(pc_out)
);

instruction_mem ins_mem_inst (
    .address(pc_out), 
    .instruction(instruction)
);

add_sub_64 add_sub_inst (
    .a(pc_out),
    .b(64'd4),
    .opcode(4'b0000), 
    .out(pc_mux_0) 
);


// IF /ID pipeline register
reg [31:0] IF_ID_instruction;
reg [63:0] IF_ID_PC;

assign IF_ID_instruction <= instruction;
assign IF_ID_PC <= pc_out;


// Instruction Decode Stage
    wire [4:0] rs1, rs2, rd;
    wire [63:0] reg_data1, reg_data2, reg_write_data;

    assign rs1 = IF_ID_instruction[19:15];
    assign rs2 = IF_ID_instruction[24:20];
    // assign rd = instruction[11:7];
    register_file reg_file_inst(
        .clk(clk),
        .reset(reset),
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(EX_MEM_rd),  
        .write_data(reg_write_data),
        .reg_write_en(MEM_WB_reg_write),    //CONTROL SIGNAL TO ADD
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );


    wire imm_out;
    ImmGen imm_gen_inst(
        .instruction(IF_ID_instruction),
        .imm_out(imm_out)
    );

    wire alu_src, mem_to_reg, reg_write, mem_read, mem_write, branch;
    wire [1:0] alu_op;

    control_unit control_inst(
        .opcode(IF_ID_instruction[6:0]),
        .ALUSrc(alu_src),
        .MemtoReg(mem_to_reg),
        .RegWrite(reg_write),
        .MemRead(mem_read),
        .MemWrite(mem_write),
        .Branch(branch),
        .ALUOp(alu_op)
    );

// ID/EX pipeline register
reg [63:0] ID_EX_reg_data1;
reg [63:0] ID_EX_reg_data2;
reg [63:0] ID_EX_imm_out; 
reg [63:0] ID_EX_PC;
reg [31:0] ID_EX_rd;

// Control Unit
reg [1:0] ID_EX_alu_op;
reg ID_EX_mem_to_reg;
reg ID_EX_mem_read;
reg ID_EX_mem_write;
reg ID_EX_branch;
reg ID_EX_alu_src;
reg ID_EX_reg_write;


assign ID_EX_reg_data1 <= reg_data1;
assign ID_EX_reg_data2 <= reg_data2;
assign ID_EX_imm_out <= imm_out;
assign ID_EX_PC <= IF_ID_PC;
assign ID_EX_rd <= IF_ID_instruction[11:7];


// Execute Stage
wire [63:0] alu_result;
wire alu_zero_flag;


wire [63:0] alu_b_in;
assign alu_b_in = ID_EX_alu_src ? ID_EX_imm_out: ID_EX_reg_data2;


wire branch_target_address;
    add_sub_64 add_sub_inst_2(
        .a(ID_EX_PC),
        .b([ID_EX_imm_out[62:0],0]),
        .opcode(4'b0000), 
        .out(branch_target_address)
    );

alu_64_bit alu_inst(
    .a(ID_EX_reg_data1),
    .b(alu_b_in),
    .opcode(alu_ctrl),
    .result(alu_result),
    .zero_flag(alu_zero_flag)
);

wire [2:0] funct3;
wire [6:0] funct7;
wire [3:0] alu_ctrl;

alu_control alu_ctrl_inst(
    .ALUOp(ID_EX_alu_op), 
    .funct3(funct3),
    .funct7(funct7),
    .ALUControl(alu_ctrl)
);


// EX/MEM REGISTERS
reg [63:0] EX_MEM_branch_target_address;
reg EX_MEM_zero_flag;
reg [63:0] EX_MEM_alu_result;
reg [63:0] EX_MEM_write_data;
reg [31:0] EX_MEM_rd;

// Control Unit
reg EX_MEM_mem_to_reg;
reg EX_MEM_mem_read;
reg EX_MEM_mem_write;
reg EX_MEM_branch;
reg EX_MEM_reg_write;


assign EX_MEM_branch_target_address <= branch_target_address;
assign EX_MEM_zero_flag <= alu_zero_flag;
assign EX_MEM_alu_result <= alu_result;
assign EX_MEM_write_data <= reg_write_data;
assign EX_MEM_rd <= ID_EX_rd;

assign EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;
assign EX_MEM_mem_read   <= ID_EX_mem_read;
assign EX_MEM_mem_write  <= ID_EX_mem_write;
assign EX_MEM_branch     <= ID_EX_branch;
assign EX_MEM_reg_write  <= ID_EX_reg_write;


// MEM STAGE
wire [63:0]read_data;

data_mem data_mem_inst(
    .clk(clk), 
    .reset(rst), 
    .address(EX_MEM_alu_result), 
    .write_data(EX_MEM_write_data), 
    .MemRead(EX_MEM_mem_read), 
    .MemWrite(EX_MEM_mem_write), 
    .read_data(read_data) 
    );



// MEM/WB REGISTERS
reg [63:0] MEM_WB_read_data;
reg [63:0] MEM_WB_alu_result;
reg [63:0] MEM_WB_rd;

reg MEM_WB_mem_to_reg;
reg MEM_WB_reg_write;

assign MEM_WB_alu_result <= EX_MEM_alu_result;
assign MEM_WB_read_data <= read_data;
assign MEM_WB_rd <= EX_MEM_rd;

assign MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;
assign MEM_WB_reg_write  <= EX_MEM_reg_write;


wire pc_mux_1;
wire branch_taken;
and(branch_taken, EX_MEM_zero_flag, EX_MEM_branch);
assign pc_mux_1 = EX_MEM_branch_target_address;

assign pc_in = branch_taken ? pc_mux_1 : pc_mux_0;

// WB STAGE
assign reg_write_data = MEM_WB_mem_to_reg ? MEM_WB_read_data: MEM_WB_alu_result;



endmodule