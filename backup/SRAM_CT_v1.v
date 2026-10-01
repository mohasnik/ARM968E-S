module SRAM_CT(
    input clk, rst,
    input w_en,
    input rd_en,
    input[31:0] address,
    input[31:0] writeData,


    output wire[31:0] readData,
    output reg ready,

    inout [15:0] SRAM_DQ,
    output reg[17:0] SRAM_ADDR,
    output  SRAM_UB_N,
    output  SRAM_LB_N,
    output reg SRAM_WE_N,
    output  SRAM_CE_N,
    output  SRAM_OE_N


);
    localparam STATE_IDLE = 0, STATE_READ_LOW = 1, STATE_READ_HIGH = 2, STATE_READ_COMPLETE = 3,
                STATE_NOP1 = 4, STATE_NOP2 = 5, STATE_WRITE_LOW = 6, STATE_WRITE_HIGH = 7;
    
    reg[2:0] ps, ns;

    wire memAccess;
    reg cntEn;
    reg cnt;
    reg rlow_en, rhigh_en;
    reg[15:0] data_low, data_high;
    reg[15:0] busData;

    always @(*) begin
        ns = STATE_IDLE;

        case(ps)
            STATE_IDLE : ns = rd_en ? STATE_READ_LOW : 
                                w_en ? STATE_WRITE_LOW : STATE_IDLE;

            STATE_READ_LOW : ns = cnt ? STATE_READ_HIGH : STATE_READ_LOW;

            STATE_READ_HIGH : ns = cnt ? STATE_READ_COMPLETE : STATE_READ_HIGH;

            STATE_READ_COMPLETE : ns = cnt ? STATE_NOP1 : STATE_READ_COMPLETE;

            STATE_NOP1 : ns = STATE_NOP2;

            STATE_NOP2 : ns = STATE_IDLE;

            STATE_WRITE_LOW : ns = cnt ? STATE_WRITE_HIGH : STATE_WRITE_LOW;

            STATE_WRITE_HIGH : ns = cnt ? STATE_NOP1 : STATE_WRITE_HIGH;
        endcase
        
    end

    always @(*) begin
        busData = 16'bZ;
        SRAM_ADDR = 16'bZ;
        SRAM_WE_N = 1'b1;
        ready = 1'b0;
        rlow_en = 1'b0;
        rhigh_en = 1'b0;
        cntEn = 1'b0;

        case(ps)
            STATE_IDLE: begin
                ready = ~memAccess;
            end

            STATE_READ_LOW : begin
                SRAM_ADDR = {address[18:2], 1'b0};
                cntEn = 1'b1;

            end

            STATE_READ_HIGH : begin
                SRAM_ADDR = {address[18:2], 1'b1};
                // data_low = SRAM_DQ;
                rlow_en = 1'b1;
                cntEn = 1'b1;

            end

            STATE_READ_COMPLETE : begin
                // data_high = SRAM_DQ;
                rhigh_en = 1'b1;
                cntEn = 1'b1;

            end

            STATE_WRITE_LOW : begin
                SRAM_ADDR = {address[18:2], 1'b0};
                SRAM_WE_N = 1'b0;
                busData = writeData[15:0];
                cntEn = 1'b1;
            end

            STATE_WRITE_HIGH : begin
                SRAM_ADDR = {address[18:2], 1'b1};
                SRAM_WE_N = 1'b0;
                busData = writeData[31:16];
                cntEn = 1'b1;
                
            end

            STATE_NOP1 : begin

            end

            STATE_NOP2: begin
                ready = 1'b1;
            end

        endcase
        
    end

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            data_low = 16'b0;
            data_high = 16'b0;
        end

        else if(rlow_en)
            data_low <= SRAM_DQ;
        else if(rhigh_en)
            data_high <= SRAM_DQ;
        
    end

    always @(posedge clk, posedge rst) begin
        if(rst)
            cnt = 1'b0;

        else if(cntEn)
            cnt <= ~cnt;
    end

     always @(posedge clk, posedge rst) begin
        if(rst) begin
            ps = STATE_IDLE;
        end

        else
            ps <= ns;
    end

    assign memAccess = w_en | rd_en;
    assign readData = {data_high, data_low};
    assign SRAM_DQ = busData;
    assign {SRAM_OE_N, SRAM_UB_N, SRAM_LB_N, SRAM_CE_N} = 4'b0000;
    
endmodule