module Hazard_unit (
    input [3:0] src1, src2, EXE_Dest,
    input  EXE_MEM_R_EN, Two_src, 
    output reg Hazard
);

    wire src1_EQ_dest_exe, src2_EQ_dest_exe;

    assign src1_EQ_dest_exe = (src1 == EXE_Dest) ? 1 : 0;
    assign src2_EQ_dest_exe = (src2 == EXE_Dest) ? 1 : 0;

    always @(*) begin
        Hazard = 1'b0;
        if(src2_EQ_dest_exe && EXE_MEM_R_EN) Hazard = 1'b1;
        if(src1_EQ_dest_exe && EXE_MEM_R_EN && Two_src) Hazard = 1'b1;
    end

    // assign Hazard = 1'b0;
endmodule