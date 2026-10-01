module cond_check(
    input [3:0] cond,
    input[3:0] SR,
    output cond_out 
    );

    wire Z, C, N, V;


    reg cond_checked;

        // Check the condition based on the condition value
        always @(*) begin
            case(cond)
                7'b0000: cond_checked = Z; //EQ
                7'b0001: cond_checked = ~Z; //NE
                7'b0010: cond_checked = C; //CS/HS
                7'b0011: cond_checked = ~C; //CC/LO
                7'b0100: cond_checked = N; //MI
                7'b0101: cond_checked = ~N; //PL
                7'b0110: cond_checked = V; //VS
                7'b0111: cond_checked = ~V; //VC
                7'b1000: cond_checked = C & (~Z); //HI
                7'b1001: cond_checked = (~C) | (Z); //LS
                7'b1010: cond_checked = ~(N ^ V); //GE
                7'b1011: cond_checked = (N ^ V);//LT
                7'b1100: cond_checked = (~Z) & (~(N ^ V)); //GT
                7'b1101: cond_checked = Z & (N ^ V); //LE
                7'b1110: cond_checked = 1'b1; //AL
                default: cond_checked = 1'b0; //NONE
            endcase
        end
    
    // Invert the cond_checked value and assign it to cond_out
    assign cond_out = ~cond_checked;

    assign {Z, C, N, V} = SR;
endmodule