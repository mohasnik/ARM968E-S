`timescale 1ns/1ps
module ADVANCE_ARM_TB();

    reg clk, rst, FW_EN;
    wire WB_EN, MEM_R_EN, MEM_W_EN, B;
    wire[3:0] EXE_CMD, status;
    wire [31:0] PC;
    
    // Instantiate the CPU and its components
    ARM_Datapath DUT (.clk(clk), .rst(rst), .WB_EN(WB_EN),.MEM_R_EN(MEM_R_EN), 
        .MEM_W_EN(MEM_W_EN),.EXE_CMD(EXE_CMD), .B(B), .status_out(status), .PC(PC), .FW_EN(FW_EN));

    // always @(posedge clk) begin
        
    // end

    // initialize test
    initial begin
        FW_EN = 1;
        rst <= 1; #220; rst<= 0;
        

        #10000 $stop;
    end


    // generate clock to sequence tests
    always begin
        clk <= 1; #1; clk <= 0; #1;
    end



endmodule