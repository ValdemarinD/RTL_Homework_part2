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
    localparam [FLEN - 1:0] four = 64'h4010_0000_0000_0000;
    localparam depth = 9;
    logic error1, error2, error3, error4;
    logic busy_1, busy_2, busy_3, busy_4, flag, flag2;
    logic [1:0] counter; 
    logic [3:0] counter2;
    logic [FLEN - 1:0] preq_res_half_1, buf_p1;
    logic [FLEN - 1:0] preq_res_half_2_1, preq_res_half_2_2;
    logic [FLEN - 1:0] preq_res;
    
    f_mult i_mult_b
    (
        .a ( b ),
        .b ( b ),
        .res (preq_res_half_1),
        .clk(clk),
        .rst(rst),
        .busy(busy_1),
        .error(error1)
    );

    always_ff @ (posedge clk) begin
        if(rst) begin
            buf_p1 <= '0;
            counter <= '0;
            flag <= '0;
        end else begin
            if(arg_vld) begin
                flag <= 1'b1;
                counter <= '0;
            end else if(flag) begin
            if(counter == 2'd2) begin
                flag <= 1'b0;
                buf_p1 <= preq_res_half_1;
                counter <= '0;
            end else
                counter <= counter + 2'd1;
            end
        end
    end

    f_mult i_mult_ac
    (
        .a ( a ),
        .b ( c ),
        .res (preq_res_half_2_1),
        .clk(clk),
        .rst(rst),
        .busy(busy_2),
        .error(error2)
    );

    f_mult i_mult_4ac
    (
        .a ( preq_res_half_2_1 ),
        .b (four),
        .res (preq_res_half_2_2),
        .clk(clk),
        .rst(rst),
        .busy(busy_3),
        .error(error3)
    );

    always_ff @ (posedge clk) begin
        if(rst) begin
            counter2 <= '0;
            flag2 <= '0;
        end else begin
            if(arg_vld) begin
                flag2 <= 1'd1;
                counter2 <= '0;
            end else if(flag2) begin
            if(counter2 == 4'd8) begin
                flag2 <= 1'b0;
                counter2 <= '0;
            end else 
                counter2 <= counter2 + 4'd1;
            end
        end
    end

    f_sub i_mult_B_4ac
    (
        .a ( buf_p1 ),
        .b ( preq_res_half_2_2 ),
        .res (res),
        .clk(clk),
        .rst(rst),
        .busy(busy_4),
        .error(error4)
    );

    logic [depth - 1:0] data;

    always_ff @ (posedge clk)
        if (rst)
            data <= '0;
        else
            data <= { data [depth - 2:0], arg_vld ? 1'b1 : 1'b0 };

    assign res_vld = data [depth - 1];

    assign res_negative = res[FLEN - 1];
    assign err = error1 | error2 | error3 | error4;
    assign busy = flag2;
    
    // проблема в том что падает сигнал от 1 
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
