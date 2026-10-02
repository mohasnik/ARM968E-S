module Forwarding_unit (   
    input [3:0] MEM_Dest, WB_Dest, src1, src2,
    input MEM_WB_EN, WB_WB_EN, FW_EN,
    output reg [1:0] src1_sel, src2_sel
);
    
    wire src1_EQ_dest_mem, src2_EQ_dest_mem, src1_EQ_dest_wb, src2_EQ_dest_wb;

    assign src1_EQ_dest_mem = (src1 == MEM_Dest) ? 1 : 0;
    assign src2_EQ_dest_mem = (src2 == MEM_Dest) ? 1 : 0;
    assign src1_EQ_dest_wb = (src1 == WB_Dest) ? 1 : 0;
    assign src2_EQ_dest_wb = (src2 == WB_Dest) ? 1 : 0;

    always @(*) begin
        src1_sel = 2'b00;
        if(FW_EN) begin
            if(src1_EQ_dest_mem && MEM_WB_EN)
                src1_sel = 2'b01;
            else if(src1_EQ_dest_wb && WB_WB_EN)
                src1_sel = 2'b10;
        end
    end

    always @(*) begin
        src2_sel = 2'b00;
        if(FW_EN) begin
            if(src2_EQ_dest_mem && MEM_WB_EN)
                src2_sel = 2'b01;
            else if(src2_EQ_dest_wb && WB_WB_EN)
                src2_sel = 2'b10;
        end
    end
endmodule
