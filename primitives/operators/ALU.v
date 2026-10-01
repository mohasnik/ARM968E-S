module alu (input signed [31:0] in1, in2, input c_in, input [3:0] EXE_CMD,
            output reg signed [31:0] result, output [3:0] status_bits);

    parameter [3:0] MOV = 4'b0001, ADD = 4'b0010, ADC = 4'b0011, SUB = 4'b0100, SBC = 4'b0101, AND = 4'b0110, ORR = 4'b0111, EOR = 4'b1000, MVN = 4'b1001; 

    wire Z, N;
    reg C, V;
    always @(*) begin
        C = 1'b0; 
        result = 32'b0;
        V = 1'b0;
        case (EXE_CMD)
            MOV: result = in2;                          //MOV
            ADD: begin                                  //STR, LSR, ADD
                {C, result} = {1'b0, in1} + {1'b0, in2};
                V = ~(in1[31] ^ in2[31]) & (result[31] ^ in1[31]);
            end           
            ADC: begin                                  //ADC
                {C, result} = {1'b0, in1} + {1'b0, in2} + {32'b0, c_in};
                V = ~(in1[31] ^ in2[31]) & (result[31] ^ in1[31]);
            end     
            SUB: begin                                  //SUB, CMP
                {C, result} = {1'b0, in1} + {1'b0, ~in2} + 33'd1;
                V = (in1[31] ^ in2[31]) & (result[31] ^ in1[31]);
            end           
            SBC: begin                                  //SBC
                {C, result} = {1'b0, in1} + {1'b0, ~in2} + {32'b0, c_in};
                V = (in1[31] ^ in2[31]) & (result[31] ^ in1[31]);
            end 
            AND: result = in1 & in2;                    //AND, TST
            ORR: result = in1 | in2;                    //ORR
            EOR: result = in1 ^ in2;                    //EOR
            MVN: result = ~(in2);                       //MVN
            // default: result = 32'b0;                 //BLT, ???
        endcase
    end


    assign status_bits = {Z, C, N, V};
    assign Z = (result == 0) ? 1'b1 : 1'b0;
    assign N = result[31];
endmodule
