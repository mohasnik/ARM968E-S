module MEM_Stage (
    input clk, rst, MEM_r_en, MEM_w_en,
    input [31:0]ALU_result, Val_Rm,
    output [31:0] MEM_result,
    output mem_freeze,

    inout [15:0] SRAM_DQ,
    output [17:0] SRAM_ADDR,
    output  SRAM_UB_N,
    output  SRAM_LB_N,
    output  SRAM_WE_N,
    output  SRAM_CE_N,
    output  SRAM_OE_N
);
    wire ready;
    // wire [15:0] SRAM_DQ;
    // wire [17:0] SRAM_ADDR;
    // wire SRAM_UB_N;
    // wire SRAM_LB_N;
    // wire SRAM_WE_N;
    // wire SRAM_CE_N;
    // wire SRAM_OE_N;

    SRAM_CT sram_ct(.clk(clk), .rst(rst), .w_en(MEM_w_en), .rd_en(MEM_r_en),
                .address(ALU_result), .readData(MEM_result), .writeData(Val_Rm),
                .ready(ready), .SRAM_DQ(SRAM_DQ), .SRAM_ADDR(SRAM_ADDR), .SRAM_UB_N(SRAM_UB_N), 
                .SRAM_LB_N(SRAM_LB_N), .SRAM_WE_N(SRAM_WE_N), .SRAM_CE_N(SRAM_CE_N), 
                .SRAM_OE_N(SRAM_OE_N)
                );
    
    
    // data_memory data_mem(.clk(clk), .MEMread(MEM_r_en), .MEMwrite(MEM_w_en), .address(ALU_result), .data(Val_Rm), .MEM_result(MEM_result));
    // SRAM_sim sram(.clk(clk), .rst(rst), .SRAM_DQ(SRAM_DQ), .SRAM_ADDR(SRAM_ADDR), .SRAM_UB_N(SRAM_UB_N), 
    //             .SRAM_LB_N(SRAM_LB_N), .SRAM_WE_N(SRAM_WE_N), .SRAM_CE_N(SRAM_CE_N), 
    //             .SRAM_OE_N(SRAM_OE_N));


    assign mem_freeze = ~ready;

    


    
endmodule