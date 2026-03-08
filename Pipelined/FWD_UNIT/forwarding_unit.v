`ifndef fwd_unit
`define fwd_unit

module forwarding_unit(
    input EX_MEM_reg_write,
    input MEM_WB_reg_write,
    input [4:0] ID_EX_rs1,
    input [4:0] ID_EX_rs2,
    input [4:0] EX_MEM_rd,
    input [4:0] MEM_WB_rd,
    output [1:0] fwd_A,
    output [1:0] fwd_B
);

wire ex_hazard_rs1;
wire ex_hazard_rs2;
wire mem_hazard_rs1;
wire mem_hazard_rs2;

assign ex_hazard_rs1 = EX_MEM_reg_write && (EX_MEM_rd != 5'd0) && (EX_MEM_rd == ID_EX_rs1);
assign ex_hazard_rs2 = EX_MEM_reg_write && (EX_MEM_rd != 5'd0) && (EX_MEM_rd == ID_EX_rs2);

assign mem_hazard_rs1 = MEM_WB_reg_write && (MEM_WB_rd != 5'd0) &&
                        !ex_hazard_rs1 && (MEM_WB_rd == ID_EX_rs1);
assign mem_hazard_rs2 = MEM_WB_reg_write && (MEM_WB_rd != 5'd0) &&
                        !ex_hazard_rs2 && (MEM_WB_rd == ID_EX_rs2);

assign fwd_A = ex_hazard_rs1 ? 2'b10 : (mem_hazard_rs1 ? 2'b01 : 2'b00);
assign fwd_B = ex_hazard_rs2 ? 2'b10 : (mem_hazard_rs2 ? 2'b01 : 2'b00);

endmodule

`endif 