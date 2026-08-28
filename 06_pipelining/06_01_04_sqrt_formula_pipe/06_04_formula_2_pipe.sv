//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);
    localparam N = 16;

    logic b_vld;
    logic [31:0] b_del;

    logic a_vld;
    logic [31:0] a_del;

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
        .x_vld(arg_vld),
        .x(c),
        .y_vld(isqrt_1_y_vld),
        .y(isqrt_1_y)
   );

   shift_register_with_valid
   #(
    .width(32),
    .depth(N)
   )

   delay_b
   (
    .clk (clk),
    .rst (rst),
    .in_vld (arg_vld),
    .in_data (b),
    .out_vld (b_vld),
    .out_data (b_del)
   );

    assign isqrt_2_x_vld = b_vld && isqrt_1_y_vld;
    assign isqrt_2_x = b_del + {16'b0, isqrt_1_y};

    isqrt isqrt_2
   (
        .clk(clk),
        .rst(rst),
        .x_vld(isqrt_2_x_vld),
        .x(isqrt_2_x),
        .y_vld(isqrt_2_y_vld),
        .y(isqrt_2_y)
   );

    shift_register_with_valid
   #(
    .width(32),
    .depth(2 * N)
   )
   
   delay_a
   (
    .clk (clk),
    .rst (rst),
    .in_vld (arg_vld),
    .in_data (a),
    .out_vld (a_vld),
    .out_data (a_del)
   );

    assign isqrt_3_x_vld = a_vld && isqrt_2_y_vld;
    assign isqrt_3_x = a_del + {16'b0, isqrt_2_y};

    isqrt isqrt_3
   (
        .clk(clk),
        .rst(rst),
        .x_vld(isqrt_3_x_vld),
        .x(isqrt_3_x),
        .y_vld(isqrt_3_y_vld),
        .y(isqrt_3_y)
   );

    assign res_vld = isqrt_3_y_vld;
    assign res = {16'b0, isqrt_3_y};
    
    // Task:
    //
    // Implement a pipelined module formula_2_pipe that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
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
