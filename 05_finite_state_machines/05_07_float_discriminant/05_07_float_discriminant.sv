//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    logic error1, error2, error3, error4;
    logic [FLEN - 1:0] preq_res_half_1;
    logic [FLEN - 1:0] preq_res_half_2_1, preq_res_half_2_2;
    logic [FLEN - 1:0] preq_res;
    
    f_mult i_mult_b
    (
        .a ( b ),
        .b ( b ),
        .res (preq_res_half_1)
    );

    f_mult i_mult_ac
    (
        .a ( a ),
        .b ( c ),
        .res (preq_res_half_2_1)
    );

    f_mult i_mult_4ac
    (
        .a ( preq_res_half_2_1 ),
        .b (64'h4010_0000_0000_0000),
        .res (preq_res_half_2_2)
    );

    f_sub i_mult_B_4ac
    (
        .a ( preq_res_half_1 ),
        .b ( preq_res_half_2_2 ),
        .res (preq_res)
    );

    function automatic logic is_invalid (input [FLEN - 1:0] val);
        if (FLEN == 32)
            return &val[30:23];
        else
            return &val[62:52];
    endfunction

    assign res_vld = arg_vld;
    assign res = preq_res;
    assign res_negative = preq_res[FLEN - 1];
    assign err = is_invalid(a) | is_invalid(b) | is_invalid(c);
    assign busy = 1'b0;

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.


endmodule
