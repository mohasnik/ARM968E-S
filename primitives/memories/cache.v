`define WAY_SIZE (64+9+1)

`define WAY_DATA(SET, WAY_NUM) SET[`WAY_SIZE*WAY_NUM + `WAY_SIZE - 1 : `WAY_SIZE*WAY_NUM + 10]
`define WAY_TAG(SET, WAY_NUM) SET[`WAY_SIZE*WAY_NUM + 10 - 1 : `WAY_SIZE*WAY_NUM + 1]
`define WAY_VALID(SET, WAY_NUM) SET[`WAY_SIZE*WAY_NUM]
`define WAY_WORD(SET, WAY_NUM, OFFSET) `WAY_DATA(SET, WAY_NUM)[OFFSET[2]*32+31 : OFFSET[2]*32]

module CACHE(
    input clk, rst, 
    input w_en,
    input rd_en,
    input[31:0] address,
    input[31:0] writeData,
    input sram_ready,

    output reg [31:0] readData,
    output sram_w_en, sram_rd_en,
    output cache_ready,
    
    
);
    localparam STATE_IDLE = 0, STATE_CACHE_WRITE = 1, STATE_SRAM_WRITE = 2, STATE_SRAM_READ_0 = 3, STATE_SRAM_READ_1 = 4;

    
    wire[8:0] tag;
    wire[5:0] index;
    wire[2:0] offset;
    wire cache_mem_w_en;
    
    wire[`WAY_SIZE*2-1:0] set;
    wire hit, hit_way_0, hit_way_1;


    reg[63:0] LRU;
    reg[`WAY_SIZE*2-1:0] mem[0:63];
    integer i;

    reg[2:0] ps, ns;


    

    always @(*) begin
        case (ps)
            STATE_IDLE: ns = w_en ? STATE_CACHE_WRITE : 
                            (rd_en & (~hit)) ? STATE_SRAM_READ_0 : STATE_IDLE;
            
            STATE_CACHE_WRITE: ns = STATE_SRAM_WRITE;

            STATE_SRAM_WRITE: ns = sram_ready ? STATE_IDLE : STATE_SRAM_WRITE;

            STATE_SRAM_READ_0: ns = sram_ready ? STATE_SRAM_READ_1 : STATE_SRAM_READ_0;

            STATE_SRAM_READ_1: ns = sram_ready ? STATE_IDLE : STATE_SRAM_READ_1;

        endcase
        
    end

    always @(*) begin
        sram_rd_en = 0;
        sram_w_en = 0;

        case (ps)

            STATE_IDLE: begin 

            end

            STATE_CACHE_WRITE: begin
                cache_mem_w_en = 1'b1;
            end

            STATE_SRAM_WRITE: begin
                sram_w_en = 1;
            end
            
        endcase
    end

    always @(*) begin
        case ({hit_way_1,hit_way_0})    
            2'b01: readData = `WAY_WORD(set, 0, offset);    
            2'b10: readData = `WAY_WORD(set, 1, offset);
            default: readData = 32'b0;
        endcase

    end

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            LRU = 0;
            ps <= STATE_IDLE;   //RESET STATE

            for (i = 0; i < 64; i = i + 1) begin
                mem[i] <= 0;
            end
        end

        else begin
            ps <= ns;

            if(cache_mem_w_en) begin
                LRU[index] <= ~LRU[index];


            end
        end
    end



    assign set = mem[index];
    assign hit_way_0 = (&{`WAY_TAG(set, 0) == tag} & `WAY_VALID(set, 0));
    assign hit_way_1 = (&{`WAY_TAG(set, 1) == tag} & `WAY_VALID(set, 1));

    assign hit = hit_way_0 | hit_way_1;
    assign {tag, index, offset} = address;
    assign cache_ready = hit;

endmodule