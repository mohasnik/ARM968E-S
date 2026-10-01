module flopr #(parameter WIDTH = 8)
            (input clk, rst,
            input [WIDTH-1:0] d,
            output reg [WIDTH-1:0] q);
    always @(posedge clk, posedge rst) begin
        if (rst) q <= 0;
        else q <= d;
    end
endmodule

module flopenr #(parameter WIDTH = 8)
            (input clk, rst, en,
            input [WIDTH-1:0] d,
            output reg [WIDTH-1:0] q);
    always @(posedge clk, posedge rst) begin
        if (rst) q <= 0;
        else if (en) q <= d;
    end
endmodule

module flopenrc #(parameter WIDTH = 8)
            (input clk, rst, clear, en,
            input [WIDTH-1:0] d,
            output reg [WIDTH-1:0] q);
    always @(posedge clk, posedge rst) begin
        if (rst) q <= 0;
        else if (en)
        if (clear) q <= 0;
        else q <= d;
    end
endmodule

module floprc #(parameter WIDTH = 8)
            (input clk,
            input rst,
            input clear,
            input [WIDTH-1:0] d,
            output reg [WIDTH-1:0] q);
    always @(posedge clk, posedge rst) begin
        if (rst) q <= 0;
        else
        if (clear) q <= 0;
        else q <= d;
    end
endmodule
