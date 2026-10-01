module EXE_Stage (
    input clk,
    input [3:0] EXE_CMD,
    input MEM_R_EN, MEM_W_EN,
    input [31:0] PC,
    input [31:0] Val_Rn, Val_Rm,
    input imm, 
    input [1:0] src1_sel, src2_sel,
    input [11:0] Shift_operand,
    input [23:0] Signed_imm_24,
    input [3:0] SR,
    input [31:0] ALU_result_mem, WB_Value,

    output [31:0] ALU_result, Br_addr,
    output [3:0] status
);

    wire mem_access;
    wire [31:0] Val1, Val2, Val2_RM_fW;
    
    mux3 #(32) Val1_mux(Val_Rn, ALU_result_mem, WB_Value, src1_sel, Val1);
    mux3 #(32) Val2_mux(Val_Rm, ALU_result_mem, WB_Value, src2_sel, Val2_RM_fW);

    alu ALU(.in1(Val1), .in2(Val2), .c_in(SR[1]), .EXE_CMD(EXE_CMD), .result(ALU_result), .status_bits(status));
    adder ADDER(.a(PC), .b({{{8{Signed_imm_24[23]}}, Signed_imm_24}<<2}), .y(Br_addr));
    val2_Generator Val2_Gen(.val_Rm(Val2_RM_fW), .imm(imm), .shift_operand(Shift_operand), .mem_access(mem_access), .val2(Val2));
    
    // assign Val1 = Val_Rn;
    assign mem_access = MEM_R_EN | MEM_W_EN;
endmodule