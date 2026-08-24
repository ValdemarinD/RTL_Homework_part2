//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output logic   res_vld,
    output logic [31:0] res
);

    logic        isqrt_1_x_vld;
    logic        [31:0] isqrt_1_x;

    logic        isqrt_1_y_vld;
    logic        [15:0] isqrt_1_y;

    logic        isqrt_2_x_vld;
    logic        [31:0] isqrt_2_x;

    logic        isqrt_2_y_vld;
    logic        [15:0] isqrt_2_y;

    logic        isqrt_3_x_vld;
    logic        [31:0] isqrt_3_x;

    logic        isqrt_3_y_vld;
    logic        [15:0] isqrt_3_y;

    logic [31:0] preq_res;

   isqrt isqrt_1
   (
        .clk(clk),
        .rst(rst),

        .x_vld(isqrt_1_x_vld),
        .x(isqrt_1_x),
        .y_vld(isqrt_1_y_vld),
        .y(isqrt_1_y)
   );

    isqrt isqrt_2
   (
        .clk(clk),
        .rst(rst),

        .x_vld(isqrt_2_x_vld),
        .x(isqrt_2_x),
        .y_vld(isqrt_2_y_vld),
        .y(isqrt_2_y)
   );

    isqrt isqrt_3
   (
        .clk(clk),
        .rst(rst),

        .x_vld(isqrt_3_x_vld),
        .x(isqrt_3_x),
        .y_vld(isqrt_3_y_vld),
        .y(isqrt_3_y)
   );

    assign isqrt_1_x_vld = arg_vld;
    assign isqrt_2_x_vld = arg_vld;
    assign isqrt_3_x_vld = arg_vld;

    assign isqrt_1_x = a;
    assign isqrt_2_x = b;
    assign isqrt_3_x = c;


    
    always_ff @ (posedge clk) begin
        if(rst) begin
            res_vld <= 1'b0;
            res <= '0;
        end
        else begin
            if (isqrt_3_y_vld && isqrt_2_y_vld && isqrt_1_y_vld)
                res <= {16'b0, isqrt_1_y} + {16'b0, isqrt_2_y} + {16'b0, isqrt_3_y};
            res_vld <= isqrt_3_y_vld && isqrt_2_y_vld && isqrt_1_y_vld;
        end
    end
    // Task:
    //
    // Implement a pipelined module formula_1_pipe that computes the result
    // of the formula defined in the file formula_1_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_1_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.org/fsm#state_0


endmodule
