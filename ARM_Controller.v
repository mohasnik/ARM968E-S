
module ARM_Controller(
    input[3:0] opcode,
    input[1:0] Mode,
    input status_in,
    output[8:0] controls
);
    reg wb_en, mem_r_en, mem_w_en, branch;
	reg status_out;
    reg [3:0] exe_cmd;


    // Modes :
    localparam MODE_ARITHMETIC = 2'b00,
                MODE_MEMORY = 2'b01,
                MODE_BRANCH = 2'b10;
    

    // opcode list :
    localparam OPC_NOP_AND = 4'b0000, 
                    OPC_MOV = 4'b1101, 
                    OPC_MVN = 4'b1111,
                    OPC_ADD = 4'b0100,
                    OPC_ADC = 4'b0101,
                    OPC_SUB = 4'b0010,
                    OPC_SBC = 4'b0110,
                    OPC_ORR = 4'b1100,
                    OPC_EOR = 4'b0001,
                    OPC_CMP = 4'b1010,
                    OPC_TST = 4'b1000,
                    OPC_MEM = 4'b0100;

    localparam ALU_MOV = 4'b0001,
                ALU_MVN = 4'b1001,
                ALU_ADD = 4'b0010,
                ALU_ADC = 4'b0011,
                ALU_SBC = 4'b0101,
                ALU_ORR = 4'b0111,
                ALU_EOR = 4'b1000,
                ALU_MEM = 4'b0010,
                ALU_SUB_CMP = 4'b0100,
                ALU_AND_TST = 4'b0110;
                


    always @(*) begin
        
        // assigning all outputs to zero for combinational result of controller :
        {wb_en, mem_r_en, mem_w_en, branch, exe_cmd} = 0;
        status_out = 1'b0;

        case (Mode)

            MODE_ARITHMETIC : begin

                wb_en = 1;
                mem_r_en = 0;
                mem_w_en = 0;
                branch = 0;
                status_out = status_in;

                case (opcode)

                    OPC_MOV :   exe_cmd = ALU_MOV;

                    OPC_MVN :   exe_cmd = ALU_MVN;

                    OPC_ADD :   exe_cmd = ALU_ADD;

                    OPC_ADC :   exe_cmd = ALU_ADC;

                    OPC_SUB :   exe_cmd = ALU_SUB_CMP;

                    OPC_SBC :   exe_cmd = ALU_SBC;

                    OPC_NOP_AND : exe_cmd = ALU_AND_TST;

                    OPC_ORR :   exe_cmd = ALU_ORR;

                    OPC_EOR :   exe_cmd = ALU_EOR;

                    OPC_CMP :   begin 
                        exe_cmd = ALU_SUB_CMP;
                        wb_en = 1'b0;
                    end

                    OPC_TST :   begin
                        exe_cmd = ALU_AND_TST;
                        wb_en = 1'b0;
                    end

                endcase

            end
            
            MODE_MEMORY : begin
                
                exe_cmd = ALU_ADD;
                wb_en = status_in;
                branch = 1'b0;

                mem_r_en = status_in ? 1'b1 : 1'b0;
                mem_w_en = status_in ? 1'b0 : 1'b1;
                // {mem_r_en, mem_w_en} = status_in ? 2'b10 : 2'b01; // status = 1 -> load, status = 0 ->  store

            end
            
            MODE_BRANCH :  begin

                {wb_en, mem_r_en, mem_w_en} = 3'b000;
                branch = opcode[3] ? 0 : 1; // checks that only when the instruction[24] is 0 , branch is valid 

            end
            
        endcase
    end
    
    // assign status_out = status_in; // status bit 

    assign controls = {wb_en, mem_r_en, mem_w_en, status_out, branch, exe_cmd}; // control outputs

endmodule