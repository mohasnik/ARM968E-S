`timescale 1ns/1ps
module ARM_TB();

    reg clk, rst, FW_EN;
    wire [15:0] SRAM_DQ;
    wire [17:0] SRAM_ADDR;
    wire SRAM_UB_N;
    wire SRAM_LB_N;
    wire SRAM_WE_N;
    wire SRAM_CE_N;
    wire SRAM_OE_N;
    
    // Instantiate the CPU and its components
    ARM_Datapath DUT (.clk(clk), .rst(rst), .FW_EN(FW_EN),.SRAM_DQ(SRAM_DQ), .SRAM_ADDR(SRAM_ADDR), .SRAM_UB_N(SRAM_UB_N), 
                .SRAM_LB_N(SRAM_LB_N), .SRAM_WE_N(SRAM_WE_N), .SRAM_CE_N(SRAM_CE_N), 
                .SRAM_OE_N(SRAM_OE_N));


    SRAM_sim sram(.clk(clk), .rst(rst), .SRAM_DQ(SRAM_DQ), .SRAM_ADDR(SRAM_ADDR), .SRAM_UB_N(SRAM_UB_N), 
                .SRAM_LB_N(SRAM_LB_N), .SRAM_WE_N(SRAM_WE_N), .SRAM_CE_N(SRAM_CE_N), 
                .SRAM_OE_N(SRAM_OE_N));
    
    // initialize test
    initial begin
        FW_EN = 1;
        rst <= 1; #220; rst<= 0;
        

        #5000 $stop;
    end


   initial begin
        $dumpfile("build/ARM_TB.vcd");

        // Dump everything under the testbench hierarchy.
        $dumpvars(0, ARM_TB);

        // Explicitly dump all register-file entries.
        $dumpvars(0, ARM_TB.DUT.ID_stage.register_file.rf[0]);
        $dumpvars(0, ARM_TB.DUT.ID_stage.register_file.rf[1]);
        $dumpvars(0, ARM_TB.DUT.ID_stage.register_file.rf[2]);
        $dumpvars(0, ARM_TB.DUT.ID_stage.register_file.rf[3]);
        $dumpvars(0, ARM_TB.DUT.ID_stage.register_file.rf[4]);
        $dumpvars(0, ARM_TB.DUT.ID_stage.register_file.rf[5]);
        $dumpvars(0, ARM_TB.DUT.ID_stage.register_file.rf[6]);
        $dumpvars(0, ARM_TB.DUT.ID_stage.register_file.rf[7]);
        $dumpvars(0, ARM_TB.DUT.ID_stage.register_file.rf[8]);
        $dumpvars(0, ARM_TB.DUT.ID_stage.register_file.rf[9]);
        $dumpvars(0, ARM_TB.DUT.ID_stage.register_file.rf[10]);
        $dumpvars(0, ARM_TB.DUT.ID_stage.register_file.rf[11]);
        $dumpvars(0, ARM_TB.DUT.ID_stage.register_file.rf[12]);
        $dumpvars(0, ARM_TB.DUT.ID_stage.register_file.rf[13]);
        $dumpvars(0, ARM_TB.DUT.ID_stage.register_file.rf[14]);
    end

    // generate clock to sequence tests
    always begin
        clk <= 1; #1; clk <= 0; #1;
    end

endmodule