`timescale 1ns/1ns
module RegisterFile(
    input clk, rst,
    input [3:0] src1, src2, dest,
    input [31:0] Result_WB,
    input writeBackEn,
    output [31:0] reg1, reg2
    );
    parameter reg_file_size = 15;
    integer i;
    reg [31 : 0] rf [0 : 14];

    always @(negedge clk, posedge rst) begin
        if(rst)
            for (i = 0; i< reg_file_size ; i=i+1)
                rf[i] <= i;
        else if(writeBackEn) rf[dest] <= Result_WB;
    end
    
    assign reg1 = rf[src1];
    assign reg2 = rf[src2];


endmodule