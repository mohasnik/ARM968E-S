`define SIZE 32
`timescale 1ns/1ns
module ARM_DP_TB();

    reg clk = 1, reset, freeze, branch_taken;
    reg[`SIZE-1:0] branch_address;
    wire[`SIZE-1:0] PC_out, inst_mem_ID;

    ARM_Datapath UUT(clk, reset, freeze, branch_taken, 
            branch_address, PC_out, inst_mem_ID);

    always #5 clk = ~clk;

    initial begin
        #0 reset = 1;
        freeze = 0;
        branch_taken = 0;
        branch_address = 0;

        #300 reset = 0;

        #353 branch_address = 6;
        #33 branch_taken = 1;
        #101 branch_taken = 0;

        #300 freeze = 1;

        #5000 $stop;



    end

    
endmodule