module IF_Stage (
    input clk, rst, freeze, Branch_taken,
    input [31:0] BranchAddr,
    output [31:0] PC, Instruction
);
    wire [31:0] PC_Next, PC_temp;
    mux2 #(32) pc_mux(PC, BranchAddr, Branch_taken, PC_Next);
    flopenr #(32) pcreg(clk, rst, ~freeze, PC_Next, PC_temp);
    adder pc_add(PC_temp, 32'h4, PC);
    inst_mem Instruction_Memory(PC_temp, Instruction);

endmodule