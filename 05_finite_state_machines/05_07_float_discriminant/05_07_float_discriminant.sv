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
    logic [FLEN - 1:0] a_r, b_r, c_r;
    
    f_mult i_mult_b
    (
        .a ( b_r ),
        .b ( b_r ),
        .res (preq_res_half_1),
        .error (error1)
    );

    f_mult i_mult_ac
    (
        .a ( a_r ),
        .b ( c_r ),
        .res (preq_res_half_2_1),
        .error (error2)
    );

    f_mult i_mult_4ac
    (
        .a ( preq_res_half_2_1 ),
        .b (64'h4010_0000_0000_0000),
        .res (preq_res_half_2_2),
        .error (error3)
    );

    f_sub i_mult_B_4ac
    (
        .a ( preq_res_half_1 ),
        .b ( preq_res_half_2_2 ),
        .res (preq_res),
        .error (error4)
    );

    always_ff @ (posedge clk) begin
        if(rst) begin
            a_r <= '0;
            b_r <= '0;
            c_r <= '0;
            res_vld <= 1'b0;
            res_negative <= 1'b0;
            err <= 1'b0;
            busy <= 1'b0;
        end else begin
            res_vld  <= 1'b0;
            if(arg_vld && !busy) begin
                busy <= 1'b1;
                a_r <= a;
                b_r <= b;
                c_r <= c;
                err <= 1'b0;
            end else if(busy) begin
                res <= preq_res;
                res_negative <= preq_res[FLEN - 1];
                err <= error1 | error2 | error3 | error4;
                busy <= 1'b0;
                res_vld <= 1'b1;
            end else
                busy <= 1'b0;    
        end        
    end 
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
