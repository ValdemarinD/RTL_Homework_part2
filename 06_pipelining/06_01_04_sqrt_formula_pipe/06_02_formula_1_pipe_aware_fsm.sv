//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    logic [31:0] buf_b;
    logic [31:0] buf_c;
    logic [31:0] sum_preq;
    logic [1:0] counter;

    enum logic [2:0]
    {
        st_idle       = 3'd0,
        st_send_b     = 3'd1,
        st_send_c     = 3'd2,
        st_wait_a_res = 3'd3,
        st_wait_b_res = 3'd4,
        st_wait_c_res = 3'd5
    }
    state, next_state;

    always_comb
    begin
        next_state = state;

        case (state)
        st_idle       : if ( arg_vld     ) next_state = st_send_b ;
        st_send_b       : next_state = st_send_c ;
        st_send_c       : next_state = st_wait_a_res ;
        st_wait_a_res : if ( isqrt_y_vld ) next_state = st_wait_b_res ;
        st_wait_b_res : if ( isqrt_y_vld ) next_state = st_wait_c_res ;
        st_wait_c_res : if ( isqrt_y_vld ) next_state = st_idle;
        endcase
    end

    always_ff @ (posedge clk) begin
        if (rst) 
            state <= st_idle;
        else
            state <= next_state;
    end

    always_ff @ (posedge clk) begin
        if (rst) begin
            buf_b <= '0;
            buf_c <= '0;
        end else if (arg_vld && state == st_idle) begin
            buf_b <= b;
            buf_c <= c;
        end
    end

    always_comb
    begin
        isqrt_x_vld = 1'b0;
        isqrt_x = 'x;

        case (state)
        st_idle :  begin
            isqrt_x_vld = arg_vld;
            isqrt_x = a;
            end
        st_send_b : begin
            isqrt_x_vld <= 1'b1;
            isqrt_x = buf_b;
        end
        st_send_c : begin 
            isqrt_x_vld = 1'b1;
            isqrt_x = buf_c;
        end

        endcase
    end

    always_ff @ (posedge clk)
        if (rst) 
            sum_preq <= '0;
        else begin
            if (state == st_idle && arg_vld)
                sum_preq <= '0;
            else if (isqrt_y_vld && state == st_wait_a_res)
                sum_preq <= {16'b0, isqrt_y};
            else if (isqrt_y_vld && state == st_wait_b_res)
                sum_preq <= sum_preq + {16'b0, isqrt_y};
        end

    always_comb begin
        res_vld = 1'b0;
        res = sum_preq;
        if(state == st_wait_c_res && isqrt_y_vld) begin
            res_vld = 1'b1;
            res = sum_preq + {16'b0, isqrt_y};
        end
    end




    // Task:
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.org/fsm#state_0


endmodule
