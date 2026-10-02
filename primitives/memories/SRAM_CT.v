module SRAM_CT(
    input clk_i, rst_i,
    input w_en_i,
    input rd_en_i,
    input[31:0] address_i,
    input[31:0] write_data_i,


    output [31:0] read_data_o,
    output reg read_data_valid_o,
    output reg busy_o,

    inout [15:0] SRAM_DQ,
    output reg[17:0] SRAM_ADDR,
    output  SRAM_UB_N,
    output  SRAM_LB_N,
    output reg SRAM_WE_N,
    output  SRAM_CE_N,
    output  SRAM_OE_N


);
    localparam STATE_IDLE = 0, STATE_RQ0LOW_W0LOW = 1, STATE_RQ0HIGH_W0HIGH = 2, STATE_RQ1LOW_W1LOW = 3, STATE_RQ1HIGH_W1HIGH = 4, STATE_RD1HIGH = 5;
    reg[2:0] ps, ns;



    reg read_store, secondAccess, writeDataAccess;
    wire memAccess;
    wire[15:0] read_data_high, read_data_low, tri_in;
    integer i;
        



    flopenr #(16) read_data_low_reg(.clk(clk_i), .rst(rst_i), .en(read_store), .d(read_data_high), .q(read_data_low));
    flopenr #(16) read_data_high_reg(.clk(clk_i), .rst(rst_i), .en(read_store), .d(SRAM_DQ), .q(read_data_high));


                    

    // controller :

    always @(*) begin
        case (ps)
            STATE_IDLE : begin
                ns = memAccess ? STATE_RQ0LOW_W0LOW : STATE_IDLE;
            end

            STATE_RQ0LOW_W0LOW : ns = STATE_RQ0HIGH_W0HIGH;

            STATE_RQ0HIGH_W0HIGH : ns = STATE_RQ1LOW_W1LOW;

            STATE_RQ1LOW_W1LOW : ns = STATE_RQ1HIGH_W1HIGH;

            STATE_RQ1HIGH_W1HIGH : ns  = STATE_RD1HIGH;

            STATE_RD1HIGH : ns = STATE_IDLE;

        endcase
    end

    always @(*) begin
        {secondAccess, read_store, writeDataAccess} = 0;
        SRAM_WE_N = 2'b11;
        SRAM_ADDR = 18'bZ;
        
        read_data_valid_o = 0;
        busy_o = 1'b1;

        case(ps)
            STATE_IDLE : begin
                busy_o = 1'b0;
            end

            STATE_RQ0LOW_W0LOW: begin
                secondAccess = 1'b0;
                SRAM_WE_N = ~w_en_i;
                writeDataAccess = w_en_i;

                SRAM_ADDR = {address_i[18:3], 1'b0, secondAccess};
            end

            STATE_RQ0HIGH_W0HIGH: begin
                secondAccess = 1'b1;
                read_store = ~w_en_i;
                SRAM_WE_N = ~w_en_i;
                writeDataAccess = w_en_i;

                SRAM_ADDR = {address_i[18:3], 1'b0, secondAccess};

            end

            STATE_RQ1LOW_W1LOW: begin
                secondAccess = 1'b0;
                SRAM_WE_N = 1'b1;
                read_store = ~w_en_i;
                writeDataAccess = w_en_i;

                SRAM_ADDR = {address_i[18:3], 1'b1, secondAccess};
                read_data_valid_o = 1'b1;
            end

            STATE_RQ1HIGH_W1HIGH : begin
                secondAccess = 1'b1;
                SRAM_WE_N = 1'b1;
                read_store = ~w_en_i;
                writeDataAccess = w_en_i;

                SRAM_ADDR = {address_i[18:3], 1'b1, secondAccess};
                
            end

            STATE_RD1HIGH : begin
                SRAM_WE_N = 1'b1;
                read_data_valid_o = 1'b1;
            end

        endcase
    end


    always @(posedge clk_i, posedge rst_i) begin
        if(rst_i)
            ps <= STATE_IDLE;
        else
            ps <= ns;
    end


    

    assign tri_in = secondAccess ? write_data_i[31:16] : write_data_i[15:0];

    assign SRAM_DQ = writeDataAccess ? tri_in : 16'bz;      // tri-state gate
    assign {SRAM_OE_N, SRAM_UB_N, SRAM_LB_N, SRAM_CE_N} = 4'b0000;
    assign memAccess = rd_en_i | w_en_i;



    
 

endmodule