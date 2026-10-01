module rotational_shifter(
    input[7:0] value,
    input[3:0] shift_amnt,
    output[31:0] rotated_val
);
    wire[4:0] shift_num = shift_amnt << 1;

    assign rotated_val = (value >> shift_num) | (value << (32 - shift_num));

endmodule