// ARM Datapath : Version 1.0.0
// Phase I : Complete ARM Multicycle description and implementation
// - M.H.Nikkhah
// - O.Gholizadeh

`timescale 1ps/1ps
module ARM_Datapath #(
    parameter arc_size = 32
)(
    clk, rst, 
    FW_EN,

    SRAM_DQ,
    SRAM_ADDR,
    SRAM_UB_N,
    SRAM_LB_N,
    SRAM_WE_N,
    SRAM_CE_N,
    SRAM_OE_N
);
    // parameters :

    localparam if_reg_size = 2* arc_size;
    localparam id_reg_size = 158;
    localparam exe_reg_size = 71;
    localparam mem_reg_size = 70;


    // input /output :

    input clk, rst;
    input FW_EN;

        
    inout [15:0] SRAM_DQ; /*SRAM required ports*/
    output [17:0] SRAM_ADDR;
    output  SRAM_UB_N;
    output  SRAM_LB_N;
    output SRAM_WE_N;
    output  SRAM_CE_N;
    output  SRAM_OE_N;

    
    // wires :
    wire freeze, flush, WB_en_WBs, WB_en_IDs, MEM_r_en_IDs, MEM_w_en_IDs,
    branch_IDs, status_IDs, imm_IDs, hazardTwoSource;

    wire WB_en_MEMs, WB_en_EXEs, MEM_r_en_MEMs, MEM_r_en_EXEs, status_reg_in, MEM_w_en_MEMs, MEM_w_en_EXEs,
        imm_EXEs, MEM_r_en_WBs, mem_freeze, hazard_freeze;

    wire [3:0] WB_Dest_WBs, WB_Dest_MEMs, SR, SR_EXEs, exe_cmd_IDs, WB_Dest_IDs, regFileSrc1, regFileSrc2, status_EXEs;

    wire [3:0] exe_cmd_EXEs,  WB_Dest_EXEs;
    
    wire [3:0] src1, src2;

    wire [11:0] shift_op_IDs, shift_op_EXEs;

    wire [23:0] simm_24_IDs, simm_24_EXEs;

    wire [arc_size-1:0] branch_address, PC_IFs, inst_IFs, PC_IDs, inst_IDs, WB_Value, Val_Rn_IDs, Val_Rm_IDs;

    wire [arc_size-1:0] PC_EXEs, Val_Rn_EXEs, Val_Rm_EXEs, Val_Rm_MEMs, ALU_result_EXEs, ALU_result_MEMs, ALU_result_WBs;
    
    wire [arc_size-1:0] PC_MEM, PC_MEMs, PC_WBs, MEM_result_MEMs, MEM_result_WBs;

    wire [1:0] src1_sel, src2_sel; 


    // instances :

    IF_Stage IF_stage(.clk(clk), .rst(rst), .freeze(freeze), .Branch_taken(flush), 
                    .BranchAddr(branch_address), .PC(PC_IFs), .Instruction(inst_IFs));

    flopenrc #(if_reg_size) IF_Stage_Reg(.clk(clk), .rst(rst), .clear(flush), .en(~freeze), 
                    .d({PC_IFs, inst_IFs}), 
                    .q({PC_IDs, inst_IDs}));

    Hazard_unit hazard_unit(.src1(regFileSrc1), .src2(regFileSrc2), .EXE_Dest(WB_Dest_EXEs), .EXE_WB_EN(WB_en_EXEs),
                    .EXE_MEM_R_EN(MEM_r_en_EXEs), .MEM_WB_EN(WB_en_MEMs), .MEM_Dest(WB_Dest_MEMs),  .Two_src(hazardTwoSource), .Hazard(hazard_freeze), .FW_EN(FW_EN));

    // ** Instruction Decode (ID) : 
    // Notes : 
    // - src1 : src1 is actually Rn.It's Just interface compatiblity perspectives.
    //

    ID_Stage  ID_stage(.clk(clk), .rst(rst), .Instruction(inst_IDs), .Result_WB(WB_Value), .writeBackEn(WB_en_WBs),
                    .Dest_wb(WB_Dest_WBs), .hazard(freeze), .SR(SR), .WB_EN(WB_en_IDs), .MEM_R_EN(MEM_r_en_IDs), 
                    .MEM_W_EN(MEM_w_en_IDs), .B(branch_IDs), .S(status_IDs), .EXE_CMD(exe_cmd_IDs), .Val_Rn(Val_Rn_IDs),
                    .Val_Rm(Val_Rm_IDs), .imm(imm_IDs), .Shift_operand(shift_op_IDs), .Signed_imm_24(simm_24_IDs),
                    .Dest(WB_Dest_IDs), .srcl(regFileSrc1), .src2(regFileSrc2), .Two_src(hazardTwoSource)); //check wb_en !!!
    

    flopenrc #(id_reg_size) ID_Stage_Reg(.clk(clk), .rst(rst), .clear(flush), 
                    .d({WB_en_IDs, MEM_r_en_IDs, MEM_w_en_IDs, exe_cmd_IDs, branch_IDs, status_IDs, PC_IDs,
                        Val_Rn_IDs, Val_Rm_IDs, shift_op_IDs, imm_IDs, simm_24_IDs, WB_Dest_IDs, SR, regFileSrc1, regFileSrc2}), 
                    .q({WB_en_EXEs, MEM_r_en_EXEs, MEM_w_en_EXEs, exe_cmd_EXEs, flush, status_reg_in, PC_EXEs,
                        Val_Rn_EXEs, Val_Rm_EXEs, shift_op_EXEs, imm_EXEs, simm_24_EXEs, WB_Dest_EXEs, SR_EXEs, src1, src2}), .en(~mem_freeze)); //branch_IDs -> flush

    EXE_Stage  EXE_stage(.clk(clk), .EXE_CMD(exe_cmd_EXEs), .MEM_R_EN(MEM_r_en_EXEs), .MEM_W_EN(MEM_w_en_EXEs), 
                    .PC(PC_EXEs), .Val_Rn(Val_Rn_EXEs), .Val_Rm(Val_Rm_EXEs), .imm(imm_EXEs), .Shift_operand(shift_op_EXEs),
                    .Signed_imm_24(simm_24_EXEs), .SR(SR_EXEs),
                    .ALU_result(ALU_result_EXEs), .Br_addr(branch_address), .status(status_EXEs), .ALU_result_mem(ALU_result_MEMs), .WB_Value(WB_Value), .src1_sel(src1_sel), .src2_sel(src2_sel));

    Forwarding_unit forwarding_unit(.MEM_Dest(WB_Dest_MEMs), .WB_Dest(WB_Dest_WBs), .src1(src1), .src2(src2), .MEM_WB_EN(WB_en_MEMs), .WB_WB_EN(WB_en_WBs), .src1_sel(src1_sel), .src2_sel(src2_sel), .FW_EN(FW_EN));

    Status_Register Status_reg(.clk(clk), .rst(rst), .status(status_EXEs), .S(status_reg_in), .SR(SR));
    
    flopenr #(exe_reg_size) EXE_Stage_Reg(.clk(clk), .rst(rst), .d({WB_en_EXEs, WB_Dest_EXEs, MEM_r_en_EXEs, MEM_w_en_EXEs, ALU_result_EXEs, Val_Rm_EXEs}),
                                    .q({WB_en_MEMs, WB_Dest_MEMs, MEM_r_en_MEMs, MEM_w_en_MEMs, ALU_result_MEMs, Val_Rm_MEMs}), .en(~mem_freeze));

    MEM_Stage  MEM_stage(.clk(clk), .rst(rst), .MEM_r_en(MEM_r_en_MEMs), .MEM_w_en(MEM_w_en_MEMs), .ALU_result(ALU_result_MEMs),
                        .Val_Rm(Val_Rm_MEMs), .MEM_result(MEM_result_MEMs), .mem_freeze(mem_freeze),
                        .SRAM_DQ(SRAM_DQ), .SRAM_ADDR(SRAM_ADDR), .SRAM_UB_N(SRAM_UB_N), .SRAM_LB_N(SRAM_LB_N), .SRAM_WE_N(SRAM_WE_N),
                        .SRAM_CE_N(SRAM_CE_N), .SRAM_OE_N(SRAM_OE_N)
                        );

    flopenr #(mem_reg_size) MEM_Stage_Reg(.clk(clk), .rst(rst), .d({WB_en_MEMs, MEM_r_en_MEMs, ALU_result_MEMs, MEM_result_MEMs, WB_Dest_MEMs}),
                             .q({WB_en_WBs, MEM_r_en_WBs, ALU_result_WBs, MEM_result_WBs, WB_Dest_WBs}), .en(~mem_freeze));

    WB_Stage  WB_stage(.ALU_result(ALU_result_WBs), .MEM_result(MEM_result_WBs), .MEM_R_en(MEM_r_en_WBs), .out(WB_Value)); // outputs : WB_EN , WB_Dest, WB_Value



    
    


    //assigns:

    //Output Assigns:
    assign WB_EN = WB_en_EXEs;
    assign PC = PC_IFs;
    assign MEM_R_EN = MEM_r_en_EXEs;
    assign MEM_W_EN = MEM_w_en_EXEs;
    assign EXE_CMD = exe_cmd_EXEs;
    assign B = branch_IDs;
    assign S = status_EXEs;
    assign status_out = SR;
    assign freeze = hazard_freeze | mem_freeze;

endmodule