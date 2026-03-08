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


    if(ID_EX_mem_read)
    begin
        if((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2))
        begin
            assign control_mux = 1'b1;
            assign pc_write = 1'b0;
            assign IF_ID_write = 1'b0;
        end

        else
        begin
            assign control_mux = 1'b0;
            assign pc_write = 1'b1;
            assign IF_ID_write = 1'b1;
        end
    end

endmodule

`endif