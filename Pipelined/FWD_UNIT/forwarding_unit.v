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


    assign fwd_A = 2'b00;
    assign fwd_b = 2'b00;

    if(EX_MEM_reg_write)
    begin
        if((EX_MEM_rd != 5'd0) && (EX_MEM_rd == ID_EX_rs1))
            begin

                assign fwd_A = 2'b10;

            end
        
        if((EX_MEM_rd != 5'd0) && (EX_MEM_rd == ID_EX_rs2))
            begin

                assign fwd_B = 2'b10;
            
            end

    end

    

    if(MEM_WB_reg_write)
    begin
        if((MEM_WB_rd != 5'd0) && 
        !(EX_MEM_reg_write && (EX_MEM_rd != 5'd0)) && 
        (EX_MEM_rd == ID_EX_rs1) && (MEM_WB_rd == ID_EX_rs1))

            begin

                assign fwd_A = 2'b01;

            end
        
        if((MEM_WB_rd != 5'd0) && 
        !(EX_MEM_reg_write && (EX_MEM_rd != 5'd0)) && 
        (EX_MEM_rd == ID_EX_rs2) && (MEM_WB_rd == ID_EX_rs2))

            begin

                assign fwd_B = 2'b01;

            end
    end

endmodule

`endif 