module rotational_shifter_TB();
    reg[7:0] val;
    reg[3:0] shift_amnt;
    wire[31:0] result;
    
    rotational_shifter DUT(.value(val), .shift_amnt(shift_amnt), .rotated_val(result));




    // task shiftCheck(input[31:0] value, input[3:0] shv);
    //     begin : myTask
    //         $display("starting task @ %0t", $time);
    //         val = value;
    //         shift_amnt = shv;
    //         sx = val << (8 - shv);
    //         #0;
    //         if(result == {sx, 16'd0,  val >> shv})
    //             $display("test passed, result value : %d", result);
    //         else 
    //             $display("test FAILED : \n\tthe result value is : %b\n\tthe expected value is : %b", result, {sx, 16'd0,  val >> shv});
            
    //         #150;
    //     end
    // endtask

    // task shiftCehckAssert(input[31:0] value, input[3:0] shv);
    //     begin : task2
    //         // $display("starting task2 @ %0t", $time);
    //         val = value;
    //         shift_amnt = shv;
    //         sx = val << (8 - shv);
    //         #0;

    //         SHIFT_CHECK: assert (result == {sx, 16'd0,  val >> shv})
    //             else begin
    //                 $error("\n******************************\n%m : Assertion SHIFT_CHECK failed!\n\t *shift amount : %d\n\t\t - result value : %b\n\t\t - expected value :%b \n\n\n", shv, result, {sx, 16'd0,  val >> shv});
    //             end
            
    //         #150;
    //     end
    // endtask

    // initial begin
    //     #100
    //    for(i = 0; i < 16; i = i+1) begin
    //         shiftCehckAssert(8'd135, i);
    //    end
    // end

    int i;

    initial begin
        #0
        val = 32'd2237;
        shift_amnt = 0;
        
        for(i = 0; i < 16; i = i + 1) begin
            #50 shift_amnt = i;

            // if(result != {val[shift_amnt-1:0], 16'd0, val[7:shift_amnt]}) begin
            //     $display("Wrong value!\n\t
            //             Expected : %b\n\t
            //             result : %b\n\n", {val[shift_amnt-1:0], 16'd0, val[7:shift_amnt]}, result);
            // end

        end
    end

endmodule