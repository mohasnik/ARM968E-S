module SRAM_CT(
    input clk, rst,
    input w_en,
    input rd_en,
    input[31:0] address,
    input[31:0] writeData,


    output[31:0] readData,
    output reg ready,

    inout [15:0] SRAM_DQ,
    output reg[17:0] SRAM_ADDR,
    output  SRAM_UB_N,
    output  SRAM_LB_N,
    output reg SRAM_WE_N,
    output  SRAM_CE_N,
    output  SRAM_OE_N


);
    localparam STATE_IDLE = 0, STATE_ACCESS_LOW = 1, STATE_ACCESS_HIGH = 2, STATE_READ_LOW = 3, STATE_NOP1 = 4, STATE_NOP2 = 5;
    reg[2:0] ps, ns;



    reg read_store, secondAccess, writeDataAccess;
    wire memAccess;
    wire[15:0] read_data_high, read_data_low, tri_in;
    // wire[17:0] mux1_out;
        

    // required Datapath :
    // adderP #(18) adder(.a(address[18:2]), .b(mux1_out), .y(SRAM_ADDR));
    flopenr #(16) read_data_low_reg(.clk(clk), .rst(rst), .en(read_store), .d(read_data_high), .q(read_data_low));
    flopenr #(16) read_data_high_reg(.clk(clk), .rst(rst), .en(read_store), .d(SRAM_DQ), .q(read_data_high));


                    





    // controller :

    always @(*) begin
        case (ps)
            STATE_IDLE : begin
                ns = memAccess ? STATE_ACCESS_LOW : STATE_IDLE;
            end

            STATE_ACCESS_LOW : ns = STATE_ACCESS_HIGH;

            STATE_ACCESS_HIGH : ns = STATE_READ_LOW;

            STATE_READ_LOW : ns = STATE_NOP1;

            STATE_NOP1 : ns  = STATE_NOP2;

            STATE_NOP2 : ns = STATE_IDLE;

        endcase
    end

    always @(*) begin
        {secondAccess, read_store, writeDataAccess} = 0;
        SRAM_WE_N = 2'b11;
        SRAM_ADDR = 18'bZ;

        case(ps)
            STATE_IDLE : begin
                ready = ~memAccess;
            end

            STATE_ACCESS_LOW: begin
                secondAccess = 1'b0;
                SRAM_WE_N = ~w_en;
                // read_store = ~w_en;
                writeDataAccess = w_en;

                SRAM_ADDR = {address[18:2], secondAccess};
            end

            STATE_ACCESS_HIGH: begin
                secondAccess = 1'b1;
                read_store = ~w_en;
                SRAM_WE_N = ~w_en;
                writeDataAccess = w_en;

                SRAM_ADDR = {address[18:2], secondAccess};

            end

            STATE_READ_LOW: begin
                SRAM_WE_N = 1'b1;
                read_store = ~w_en;
            end

            STATE_NOP1 : begin
                SRAM_WE_N = 1'b1;
            end

            STATE_NOP2 : begin
                SRAM_WE_N = 1'b1;
                ready = 1'b1;
            end

        endcase
    end


    always @(posedge clk, posedge rst) begin
        if(rst)
            ps <= STATE_IDLE;
        else
            ps <= ns;
    end


    

    // assign mux1_out = {{17{1'b0}}, secondAccess};
    // assign SRAM_ADDR = {address[18:2], secondAccess};
    assign tri_in = secondAccess ? writeData[31:16] : writeData[15:0];

    assign SRAM_DQ = writeDataAccess ? tri_in : 16'bz;      // tri-state gate
    assign readData = {read_data_high, read_data_low};
    assign {SRAM_OE_N, SRAM_UB_N, SRAM_LB_N, SRAM_CE_N} = 4'b0000;
    assign memAccess = rd_en | w_en;



    
 

endmodule