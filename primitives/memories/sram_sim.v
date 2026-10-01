module SRAM_sim #(
    parameter size = 2048
)(
    input clk, rst,
    inout [15:0] SRAM_DQ,
    input [17:0] SRAM_ADDR,
    input SRAM_UB_N,
    input SRAM_LB_N,
    input SRAM_WE_N,
    input SRAM_CE_N,
    input SRAM_OE_N
);
    reg [15:0] sram[0:size-1];
    reg[15:0] data;
    integer i;

    initial begin
        
        for (i = 0; i < size-1; i = i + 1) begin
            sram[i] <= 16'b0;
        end
    end


    
    always @(posedge clk, posedge rst) begin
        if(rst)
            data = 16'bZ;

        else if(~SRAM_WE_N) begin
            sram[SRAM_ADDR[10:0]] <= SRAM_DQ;
        end
        else if(SRAM_WE_N) begin
            data <= sram[SRAM_ADDR[10:0]];
        end
    end


    assign SRAM_DQ = SRAM_WE_N ? data : 16'bZ;

endmodule