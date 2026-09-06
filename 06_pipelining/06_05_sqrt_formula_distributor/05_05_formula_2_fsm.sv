//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_fsm
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
        // FSM

    enum logic [2:0]
    {
        st_idle       = 3'd0,
        st_wait_c_res = 3'd1,
        st_wait_b_res = 3'd2,
        st_wait_a_res = 3'd3
    }
    state, next_state;

    logic [31:0] a_reg, b_reg;

    always_ff @ (posedge clk) begin
        if(rst) begin
            a_reg <= '0;
            b_reg <= '0;
        end else if( arg_vld && state == st_idle ) begin
            a_reg <= a;
            b_reg <= b;
        end
    end

    always_comb
    begin
        next_state = state;

        case (state)
        st_idle       : if ( arg_vld     ) next_state = st_wait_c_res ;
        st_wait_c_res : if ( isqrt_y_vld ) next_state = st_wait_b_res ;
        st_wait_b_res : if ( isqrt_y_vld ) next_state = st_wait_a_res ;
        st_wait_a_res : if ( isqrt_y_vld ) next_state = st_idle       ;
        endcase
    end

    always_ff @ (posedge clk)
        if (rst)
            state <= st_idle;
        else
            state <= next_state;

    // Datapath

    always_comb
    begin
        isqrt_x_vld = 1'b0;
        isqrt_x = '0;

        case (state)
        st_idle       : begin isqrt_x_vld = arg_vld; isqrt_x = c; end

        st_wait_c_res : begin isqrt_x_vld = isqrt_y_vld; isqrt_x = b_reg + {16'b0, isqrt_y}; end
        st_wait_b_res : begin isqrt_x_vld = isqrt_y_vld; isqrt_x = a_reg + {16'b0, isqrt_y}; end
        endcase
    end

    // The result

    always_ff @ (posedge clk) begin 
        if (rst) begin
            res_vld <= '0;
            res <= '0;
        end else begin
            res_vld <= (state == st_wait_a_res && isqrt_y_vld);
            if (state == st_wait_a_res && isqrt_y_vld)
                res <= {16'b0, isqrt_y};
        end
    end



    // Task:
    //
    // Implement a module that calculates the formula from the `formula_2_fn.svh` file
    // using only one instance of the isqrt module.
    //
    // Design the FSM to calculate answer step-by-step and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.org/fsm#state_0


endmodule
