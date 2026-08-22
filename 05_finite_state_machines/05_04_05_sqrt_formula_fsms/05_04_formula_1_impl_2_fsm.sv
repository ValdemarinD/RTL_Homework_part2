//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_impl_2_fsm
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

    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,

    input               isqrt_1_y_vld,
    input        [15:0] isqrt_1_y,

    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,

    input               isqrt_2_y_vld,
    input        [15:0] isqrt_2_y
);
    logic flag;
        
    enum logic [2:0]
    {
        st_idle       = 3'd0,
        st_wait_a_res = 3'd1,
        st_wait_b_res = 3'd2,
        st_wait_c_res = 3'd3
    }
    state1, next_state1, state2, next_state2;

    always_comb
    begin
        next_state1 = state1;

        case (state1)
        st_idle       : if ( arg_vld     ) next_state1 = st_wait_a_res ;
        st_wait_a_res : if ( isqrt_1_y_vld ) next_state1 = st_wait_b_res ;
        st_wait_b_res : if ( isqrt_1_y_vld ) next_state1 = st_idle       ;
        endcase
    end

    always_comb
    begin
        next_state2 = state2;

        case(state2)
        st_idle      : if(arg_vld) next_state2 = st_wait_c_res;
        st_wait_c_res: if(isqrt_2_y_vld ) next_state2 = st_idle;
        endcase
    end

    always_ff @ (posedge clk)
        if (rst) begin
            state1 <= st_idle;
            state2 <= st_idle;
            flag <= 1'b0;
        end else begin
            state1 <= next_state1;
            state2 <= next_state2;
        end

    // Datapath

    always_comb
    begin
        isqrt_1_x_vld = '0;

        case (state1)
        st_idle       : isqrt_1_x_vld = arg_vld;

        st_wait_a_res : isqrt_1_x_vld = isqrt_1_y_vld;
        endcase
    end

    always_comb
    begin
        isqrt_1_x = 'x;  // Don't care

        case (state1)
        st_idle       : isqrt_1_x = a;
        st_wait_a_res : isqrt_1_x = b;
        endcase
    end

    // second part

    always_comb
    begin
        isqrt_2_x_vld = '0;

        case (state2)
        st_idle       : isqrt_2_x_vld = arg_vld;
        endcase
    end

    always_comb
    begin
        isqrt_2_x = 'x;  // Don't care

        case (state2)
        st_idle       : isqrt_2_x = c;
        endcase
    end
    // The result

    always_ff @ (posedge clk)
        if (rst)
            res_vld <= '0;
        else
            res_vld <= (state1 == st_wait_b_res && isqrt_1_y_vld && (flag || isqrt_2_y_vld));

    always_ff @ (posedge clk)
        if (state1 == st_idle && state2 == st_idle && arg_vld)
            res <= '0;
        else begin
            if(isqrt_2_y_vld == 1'b1)
                flag <= 1'b1;
            if (isqrt_1_y_vld && isqrt_2_y_vld)
                res <= res + isqrt_1_y + isqrt_2_y;
            else if (isqrt_1_y_vld)
                res <= res + isqrt_1_y;
            else if (isqrt_2_y_vld)
                res <= res + isqrt_2_y;
            end

    // Task:
    // Implement a module that calculates the formula from the `formula_1_fn.svh` file
    // using two instances of the isqrt module in parallel.
    //
    // Design the FSM to calculate an answer and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.org/fsm#state_0


endmodule
