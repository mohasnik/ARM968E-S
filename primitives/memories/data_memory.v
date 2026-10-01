`timescale 1ns/1ns
module data_memory (
    input clk, MEMread, MEMwrite,
    input [31:0]address, data,
    output reg [31:0] MEM_result
);
    reg [31:0] RAM[0:63];
    wire [31:0] a;

    always @(posedge clk) begin
        if (MEMwrite) RAM[a[31:2]] <= data;
    end

    always @(*) begin
        if (MEMread) MEM_result <= RAM[a[31:2]];
        else MEM_result <= 32'b0;
    end


    assign a = address - 12'b010000000000;



   
endmodule