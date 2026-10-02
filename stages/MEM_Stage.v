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
    wire [31:0] sram_read_data;
    wire        sram_data_valid;
    wire        sram_busy;
    wire [31:0] sram_write_data;
    wire        sram_w_en;
    wire        sram_rd_en;

    CACHE cache (
        .clk_i(clk),
        .rst_i(rst),
        .w_en_i(MEM_w_en),
        .rd_en_i(MEM_r_en),
        .address(ALU_result),
        .write_data_i(Val_Rm),
        .read_data_o(MEM_result),
        .sram_busy_i(sram_busy),
        .sram_read_data_i(sram_read_data),
        .sram_data_valid_i(sram_data_valid),
        .sram_write_data_o(sram_write_data),
        .sram_w_en_o(sram_w_en),
        .sram_rd_en_o(sram_rd_en),
        .cache_ready_o(ready)
    );

    SRAM_CT sram_ct (
        .clk_i(clk),
        .rst_i(rst),
        .w_en_i(sram_w_en),
        .rd_en_i(sram_rd_en),
        .address_i(ALU_result),
        .write_data_i(sram_write_data),
        .read_data_o(sram_read_data),
        .read_data_valid_o(sram_data_valid),
        .busy_o(sram_busy),
        .SRAM_DQ(SRAM_DQ),
        .SRAM_ADDR(SRAM_ADDR),
        .SRAM_UB_N(SRAM_UB_N),
        .SRAM_LB_N(SRAM_LB_N),
        .SRAM_WE_N(SRAM_WE_N),
        .SRAM_CE_N(SRAM_CE_N),
        .SRAM_OE_N(SRAM_OE_N)
    );
    
    
    


    assign mem_freeze = ~ready & (MEM_r_en | MEM_w_en);

    


    
endmodule
