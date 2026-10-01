module Status_Register (
    input clk, rst,
    input[3:0] status,
    input S,
    output reg[3:0] SR
);

    always @(negedge clk, posedge rst) begin
        if(rst)
            SR <= 0;
        else if(S)
            SR <= status;
    end
endmodule