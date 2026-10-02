// `define WAY_SIZE (64+9+1)

// `define WAY_DATA(SET, WAY_NUM) SET[`WAY_SIZE*WAY_NUM + `WAY_SIZE - 1 : `WAY_SIZE*WAY_NUM + 10]
// `define WAY_TAG(SET, WAY_NUM) SET[`WAY_SIZE*WAY_NUM + 10 - 1 : `WAY_SIZE*WAY_NUM + 1]
// `define WAY_VALID(SET, WAY_NUM) SET[`WAY_SIZE*WAY_NUM]
// `define WAY_WORD(SET, WAY_NUM, OFFSET) `WAY_DATA(SET, WAY_NUM)[OFFSET[2]*32+31 : OFFSET[2]*32]

module CACHE(
    input clk_i,
    input rst_i,

    input        w_en_i,
    input        rd_en_i,
    input [31:0] address,
    input [31:0] write_data_i,

    input        sram_busy_i,
    input [31:0] sram_read_data_i,
    input sram_data_valid_i,

    output reg [31:0] read_data_o,
    output reg [31:0] sram_write_data_o,
    output reg        sram_w_en_o,
    output reg        sram_rd_en_o,
    output reg        cache_ready_o
);
    localparam [2:0]
        STATE_IDLE        = 3'd0,
        STATE_CACHE_WRITE = 3'd1,
        STATE_SRAM_WRITE  = 3'd2,
        STATE_SRAM_READ = 3'd3;
        

    
    localparam integer SETS = 64;
    localparam integer WAYS = 2;
    localparam integer WORDS_PER_LINE = 2;

    localparam integer INDEX_WIDTH = $clog2(SETS);
    localparam integer OFFSET_WIDTH = $clog2(WORDS_PER_LINE * 4);
    localparam integer TAG_WIDTH = 8;

    reg[2:0] ps, ns;

    wire[TAG_WIDTH-1:0] tag;
    wire[INDEX_WIDTH-1:0] index;
    wire[OFFSET_WIDTH-1:0] offset;
    
    reg [31:0] data_array  [0:SETS-1][0:WAYS-1][0:WORDS_PER_LINE-1];
    reg [TAG_WIDTH-1:0]  tag_array   [0:SETS-1][0:WAYS-1];
    reg valid_array [0:SETS-1][0:WAYS-1];
    reg [63:0] LRU_array;


    reg cache_mem_w_en;
    wire set_LRU;
    wire hit, hit_way_0, hit_way_1;

    wire [31:0] cache_write_data;
    reg cache_wdata_select;
    wire selected_way;

    integer i, j, k;


    always @(*) begin
        ns = STATE_IDLE;

        case (ps)
            STATE_IDLE: begin
                ns = w_en_i ? (hit ? STATE_CACHE_WRITE : STATE_SRAM_WRITE) :  (rd_en_i & (~hit)) ? (STATE_SRAM_READ) : STATE_IDLE;
            end

            STATE_CACHE_WRITE: begin
                ns = STATE_SRAM_WRITE;
            end

            STATE_SRAM_WRITE: begin
                ns = sram_busy_i ? STATE_SRAM_WRITE : STATE_IDLE;
            end

            STATE_SRAM_READ: begin
                ns = sram_busy_i ? STATE_SRAM_WRITE : STATE_IDLE;
            end
            
        endcase
    end


    
    always @(*) begin
        read_data_o = '0;
        cache_ready_o = 0;
        cache_mem_w_en = 0;
        cache_wdata_select = '0;
        sram_w_en_o = 1'b0;
        sram_rd_en_o = 1'b0;

        case (ps)
            STATE_IDLE: begin
                read_data_o = hit_way_0 ? data_array[index][0][address[3]] : 
                            hit_way_1 ? data_array[index][1][address[3]] : '0;

                cache_ready_o = hit;
                
            end

            STATE_CACHE_WRITE: begin
                cache_mem_w_en = 1'b1;
                cache_wdata_select = 1'b0;
            end

            STATE_SRAM_WRITE: begin

                sram_w_en_o = 1; 

            end

            STATE_SRAM_READ: begin
                sram_rd_en_o = ~sram_busy_i;
                cache_mem_w_en = sram_data_valid_i;
                cache_wdata_select = 1'b1;
            end
            
        endcase
    end
    

    always @(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            LRU_array <= '0;
            ps <= STATE_IDLE;

            for (i = 0; i < SETS; i = i + 1) begin
                for (j = 0; j < WAYS; j = j + 1) begin
                    tag_array[i][j] <= '0;
                    valid_array[i][j] <= 1'b0;

                    for (k = 0; k < WORDS_PER_LINE; k = k + 1) begin
                        data_array[i][j][k] <= '0;
                    end
                end
            end
        end
        else begin
            ps <=  ns;

            if (cache_mem_w_en) begin
                data_array[index][selected_way][address[3]] <= cache_write_data;
                tag_array[index][selected_way] <= tag;
                valid_array[index][selected_way] <= 1'b1;
                LRU_array[index] <= ~selected_way;
            end
        end
    end

    assign hit_way_0 = valid_array[index][0] && (tag_array[index][0] == tag);
    assign hit_way_1 = valid_array[index][1] && (tag_array[index][1] == tag);
    assign hit = hit_way_0 | hit_way_1;
    assign set_LRU = LRU_array[index];
    assign selected_way = hit_way_0 ? 1'b0 :
                          hit_way_1 ? 1'b1 : set_LRU;




    assign {tag, index, offset} = address;
    
    assign cache_write_data = cache_wdata_select ? sram_read_data_i : write_data_i;
    

endmodule
