`timescale 1ns/1ns
module ID_Stage (
    input clk, rst,
    //from IF Reg
    input [31 : 0] Instruction,
    //from WB stage
    input [31 : 0] Result_WB,
    input writeBackEn,
    input [3 : 0] Dest_wb,
    //from hazard detect module
    input hazard,
    //from Status Register
    input [3 : 0] SR,
    //to next stage
    output WB_EN, MEM_R_EN, MEM_W_EN, B, S,
    output [3 : 0] EXE_CMD,
    // Val_Rn and Val_Rm are register File outputs
    output [31 : 0] Val_Rn, Val_Rm,
    output imm,
    output [11 : 0] Shift_operand,
    output [23 : 0] Signed_imm_24,
    output [3 : 0] Dest,
    //to hazard detect module
    output [3 : 0] srcl, src2,
    output Two_src
    );
    

    wire[8:0] controls;
    wire[3:0] opcode, Rn, Rm, Rd, cond;
    wire[1:0] Mode;
    wire cond_out;

    ARM_Controller controller(.opcode(opcode), .Mode(Mode), .status_in(status_in), 
                    .controls(controls));
    
    
    RegisterFile register_file(.clk(clk), .rst(rst), .src1(Rn), .src2(src2), .dest(Dest_wb),
                                .Result_WB(Result_WB), .writeBackEn(writeBackEn), 
                                .reg1(Val_Rn), .reg2(Val_Rm));

    cond_check condition_check(.cond(cond), .SR(SR), .cond_out(cond_out));

    mux2 #(4) src2_mux(.d0(Rm), .d1(Rd), .s(MEM_W_EN), .y(src2));

    mux2 #(9) control_mux(.d0(controls), .d1(9'b0), .s(control_sel), 
                            .y({WB_EN, MEM_R_EN, MEM_W_EN, S, B, EXE_CMD}));
    


    // instruction decode :
    assign cond = Instruction[31:28];
    assign Rn = Instruction[19:16];
    assign Rm = Instruction[3:0];
    assign Rd = Instruction[15:12];
    assign opcode = Instruction[24:21];
    assign status_in = Instruction[20];
    assign Mode = Instruction[27:26];

    // Boolean functions:

    assign control_sel = hazard | cond_out;
    

    // outputs : 
    assign imm = Instruction[25];
    assign Shift_operand = Instruction[11:0];
    assign Signed_imm_24 = Instruction[23:0];
    assign Dest = Instruction[15:12];
    assign Two_src = MEM_W_EN | ~(imm);
    assign srcl = Rn;

  
endmodule