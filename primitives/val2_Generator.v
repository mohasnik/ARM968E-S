module val2_Generator(
    val_Rm, imm, shift_operand, mem_access, val2
);
    // inputs / outputs:
    input[31:0] val_Rm;
    input imm, mem_access;
    input[11:0] shift_operand;
    output reg[31:0] val2;


    // parameters : 
    localparam[1:0] IMM_SHIFT_LSL = 2'b00, IMM_SHIFT_LSR = 2'b01,
                    IMM_SHIFT_ASR = 2'b10, IMM_SHIFT_ROR = 2'b11;
    
    // wires / regs :
    wire[63:0] rotated_val_Rm;
    wire[31:0] rotated_val;
    wire[31:0] sh_operand_ext;
    
    // modules :
    rotational_shifter shifter(.value(shift_operand[7:0]), .shift_amnt(shift_operand[11:8]),
                                .rotated_val(rotated_val));


    always @(val_Rm, imm, shift_operand, mem_access, rotated_val, sh_operand_ext) begin
        val2 = 32'd0;

        casex ({mem_access, imm}) //synthesis-parallel-case
            2'b1x : begin
                val2 = sh_operand_ext;
            end

            2'b01: begin
                val2 = rotated_val;
            end

            2'b00: begin
                if(shift_operand[4] == 1'b0) begin
                    case (shift_operand[6:5])
                        IMM_SHIFT_LSL: begin
                            val2 = val_Rm << shift_operand[11:7];
                        end

                        IMM_SHIFT_LSR: begin
                            val2 = val_Rm >> shift_operand[11:7];
                        end

                        IMM_SHIFT_ASR: begin
                            val2 = $signed(val_Rm) >>> shift_operand[11:7];
                        end

                        IMM_SHIFT_ROR: begin
                            val2 = (val_Rm >> shift_operand[11:7]) | (val_Rm << (32 - shift_operand[11:7]));
                        end
                    endcase
                end
            end
        endcase
    end



    assign sh_operand_ext = {{20{shift_operand[11]}}, shift_operand};
    assign rotated_val_Rm = rotated_val_Rm >> shift_operand[11:7];
    
endmodule