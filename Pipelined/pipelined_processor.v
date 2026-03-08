`timescale 1ns/1ps

`include "ALU/alu.v"
`include "ALU_CTRL/AluCtrl.v"
`include "CONTROL_UNIT/control_unit.v"
`include "DATA_MEM/data_mem.v"
`include "IMM_GEN/ImmGen.v"
`include "INS_MEM/instruction_mem.v"
`include "PC/pc.v"
`include "REGISTER_FILE/reg_file.v"
`include "FWD_UNIT/forwarding_unit.v"
`include "DATA_HAZARD_UNIT/data_hazard_unit.v"

module pipelined_processor(
    input clk,
    input rst
);





//  Instruction Fetch Stage

wire [63:0] pc_mux_0;
wire [63:0] pc_out;
wire [63:0] pc_in;
wire [31:0] instruction;

pc pc_inst (
    .clk(clk),
    .rst(rst),
    .pc_in(pc_in), 
    .pc_out(pc_out),
    .pc_write(pc_write)
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

always @(posedge clk or posedge rst) 
begin

    if(rst || branch_taken)begin  // flush on branch taken
        IF_ID_instruction <= 32'd0;
        IF_ID_PC <= 64'd0;
    end else begin
        if(IF_ID_write) begin
            IF_ID_instruction <= instruction;
            IF_ID_PC <= pc_out;
        end else begin
            IF_ID_instruction <= IF_ID_instruction;
            IF_ID_PC <= IF_ID_PC;
        end
    end
end

// Instruction Decode Stage
    wire [4:0] rs1, rs2, rd;
    wire [63:0] reg_data1, reg_data2, reg_write_data;

    assign rs1 = IF_ID_instruction[19:15];
    assign rs2 = IF_ID_instruction[24:20];
    // assign rd = instruction[11:7];
    register_file reg_file_inst(
        .clk(clk),
        .reset(rst),
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(MEM_WB_rd),   // CORRECT
        .write_data(reg_write_data),
        .reg_write_en(MEM_WB_reg_write),    //CONTROL SIGNAL TO ADD
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );


    wire pc_write, IF_ID_write, control_mux;

    data_hazard_unit data_hazard_inst(
        .ID_EX_mem_read(ID_EX_mem_read),
        .ID_EX_rd(ID_EX_rd),
        .IF_ID_rs1(rs1),
        .IF_ID_rs2(rs2),
        .pc_write(pc_write),
        .IF_ID_write(IF_ID_write),
        .control_mux(control_mux)
    );


    

    wire [63:0] imm_out;
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
reg [4:0] ID_EX_rd;
reg [4:0] ID_EX_rs1;
reg [4:0] ID_EX_rs2;
reg [31:0] ID_EX_instruction;  // add to ID/EX register

// Control Unit
reg [1:0] ID_EX_alu_op;
reg ID_EX_mem_to_reg;
reg ID_EX_mem_read;
reg ID_EX_mem_write;
reg ID_EX_branch;
reg ID_EX_alu_src;
reg ID_EX_reg_write;

always @(posedge clk or posedge rst) 
begin
    if(rst || branch_taken)  // flush on branch taken
    begin
        ID_EX_reg_data1 <= 64'd0;
        ID_EX_reg_data2 <= 64'd0;
        ID_EX_imm_out <= 64'd0;
        ID_EX_PC <= 64'd0;
        ID_EX_rd <= 5'd0;
        ID_EX_rs1 <= 5'd0;
        ID_EX_rs2 <= 5'd0;
        ID_EX_instruction <= 32'd0;
        ID_EX_alu_op     <= 2'b00;
        ID_EX_mem_to_reg <= 1'b0;
        ID_EX_mem_read   <= 1'b0;
        ID_EX_mem_write  <= 1'b0;
        ID_EX_branch     <= 1'b0;
        ID_EX_alu_src    <= 1'b0;
        ID_EX_reg_write  <= 1'b0;
    end
    else begin
    ID_EX_reg_data1 <= reg_data1;
    ID_EX_reg_data2 <= reg_data2;
    ID_EX_imm_out <= imm_out;
    ID_EX_PC <= IF_ID_PC;
    ID_EX_rd <= IF_ID_instruction[11:7];
    ID_EX_rs1 <= rs1;
    ID_EX_rs2 <= rs2;
    ID_EX_instruction <= IF_ID_instruction; // latch it

        if(control_mux) 
        begin
            ID_EX_alu_op     <= 2'b00;
            ID_EX_mem_to_reg <= 1'b0;
            ID_EX_mem_read   <= 1'b0;
            ID_EX_mem_write  <= 1'b0;
            ID_EX_branch     <= 1'b0;
            ID_EX_alu_src    <= 1'b0;
            ID_EX_reg_write  <= 1'b0;
        end

        else
        begin
            ID_EX_alu_op     <= alu_op;
            ID_EX_mem_to_reg <= mem_to_reg;
            ID_EX_mem_read   <= mem_read;
            ID_EX_mem_write  <= mem_write;
            ID_EX_branch     <= branch;
            ID_EX_alu_src    <= alu_src;
            ID_EX_reg_write  <= reg_write;
        end
    end
end

// Execute Stage
wire [63:0] alu_result;
wire alu_zero_flag;

// Branch resolved in EX stage (static not-taken prediction)
wire branch_taken;
assign branch_taken = ID_EX_branch & alu_zero_flag;
assign pc_in = branch_taken ? branch_target_address : pc_mux_0;

wire [63:0] alu_b_in;
reg  [63:0] alu_a_in;
reg  [63:0] alu_pre_b_in;

always @(*) begin
    case (fwd_A)
        2'b00: alu_a_in = ID_EX_reg_data1;
        2'b01: alu_a_in = reg_write_data;
        2'b10: alu_a_in = EX_MEM_alu_result;
        default: alu_a_in = ID_EX_reg_data1;
    endcase
    case (fwd_B)
        2'b00: alu_pre_b_in = ID_EX_reg_data2;
        2'b01: alu_pre_b_in = reg_write_data;
        2'b10: alu_pre_b_in = EX_MEM_alu_result;
        default: alu_pre_b_in = ID_EX_reg_data2;
    endcase
end

assign alu_b_in = ID_EX_alu_src ? ID_EX_imm_out: alu_pre_b_in;


wire [63:0] branch_target_address;
    add_sub_64 add_sub_inst_2(
        .a(ID_EX_PC),
        .b({ID_EX_imm_out[62:0], 1'b0}),
        .opcode(4'b0000), 
        .out(branch_target_address)
    );

alu_64_bit alu_inst(
    .a(alu_a_in),
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

assign funct3 = ID_EX_instruction[14:12];
assign funct7 = ID_EX_instruction[31:25];

wire [1:0] fwd_A;
wire [1:0] fwd_B;

forwarding_unit forwarding_unit_inst(
    .EX_MEM_reg_write(EX_MEM_reg_write),
    .MEM_WB_reg_write(MEM_WB_reg_write),
    .ID_EX_rs1(ID_EX_rs1),
    .ID_EX_rs2(ID_EX_rs2),
    .EX_MEM_rd(EX_MEM_rd),
    .MEM_WB_rd(MEM_WB_rd),
    .fwd_A(fwd_A),
    .fwd_B(fwd_B)
);



// EX/MEM REGISTERS
reg [63:0] EX_MEM_branch_target_address;
reg EX_MEM_zero_flag;
reg [63:0] EX_MEM_alu_result;
reg [63:0] EX_MEM_write_data;
reg [4:0] EX_MEM_rd;

// Control Unit
reg EX_MEM_mem_to_reg;
reg EX_MEM_mem_read;
reg EX_MEM_mem_write;
reg EX_MEM_branch;
reg EX_MEM_reg_write;

always @(posedge clk or posedge rst)
begin

    if(rst) begin
        EX_MEM_branch_target_address <= 64'd0;
        EX_MEM_zero_flag <= 1'b0;
        EX_MEM_alu_result <= 64'd0;
        EX_MEM_write_data <= 64'd0;
        EX_MEM_rd <= 5'd0;

        EX_MEM_mem_to_reg <= 1'b0;
        EX_MEM_mem_read   <= 1'b0;
        EX_MEM_mem_write  <= 1'b0;
        EX_MEM_branch     <= 1'b0;
        EX_MEM_reg_write  <= 1'b0;
    end else begin
        EX_MEM_branch_target_address <= branch_target_address;
        EX_MEM_zero_flag <= alu_zero_flag;
        EX_MEM_alu_result <= alu_result;
        EX_MEM_write_data <= alu_pre_b_in;    // CORRECT — forwarded rs2 value
        EX_MEM_rd <= ID_EX_rd;

        EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;
        EX_MEM_mem_read   <= ID_EX_mem_read;
        EX_MEM_mem_write  <= ID_EX_mem_write;
        EX_MEM_branch     <= ID_EX_branch;
        EX_MEM_reg_write  <= ID_EX_reg_write;
    end
end

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

// Branch resolved in EX stage — pc_in and branch_taken assigned there


// MEM/WB REGISTERS
reg [63:0] MEM_WB_read_data;
reg [63:0] MEM_WB_alu_result;
reg [4:0] MEM_WB_rd;

reg MEM_WB_mem_to_reg;
reg MEM_WB_reg_write;


always @(posedge clk or posedge rst)
begin
    if(rst)
    begin 
        MEM_WB_alu_result <= 64'd0;
        MEM_WB_read_data  <= 64'd0;
        MEM_WB_rd         <= 5'd0;
        MEM_WB_mem_to_reg <= 1'b0;
        MEM_WB_reg_write  <= 1'b0;

    end
    else
    begin
        MEM_WB_alu_result <= EX_MEM_alu_result;
        MEM_WB_read_data <= read_data;
        MEM_WB_rd <= EX_MEM_rd;
        MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;
        MEM_WB_reg_write  <= EX_MEM_reg_write;
    end
end



// WB STAGE
assign reg_write_data = MEM_WB_mem_to_reg ? MEM_WB_read_data: MEM_WB_alu_result;



endmodule