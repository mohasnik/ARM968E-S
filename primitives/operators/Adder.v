module adder(input [31:0] a, b,
            output [31:0] y);
    assign y = a + b;
endmodule


module adderP #(
    parameter size = 18
) (
    input[size-1:0] a, b,
    output[size-1:0] y
);
    assign y = a + b;
    
endmodule