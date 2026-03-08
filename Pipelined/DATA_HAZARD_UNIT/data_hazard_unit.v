`ifndef data_hazard_unit
`define data_hazard_unit

module data_hazard_unit(
    input ID_EX_mem_read,
    input [4:0] ID_EX_rd,
    input [4:0] IF_ID_rs1,
    input [4:0] IF_ID_rs2,
    output pc_write,
    output IF_ID_write,
    output control_mux
);

wire load_use_hazard;

assign load_use_hazard = ID_EX_mem_read &&
                        (ID_EX_rd != 5'd0) &&
                        ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2));

assign control_mux = load_use_hazard;
assign pc_write = ~load_use_hazard;
assign IF_ID_write = ~load_use_hazard;

endmodule

`endif