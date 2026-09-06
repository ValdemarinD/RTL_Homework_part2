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
        
    enum logic [1:0]
    {
        st1_idle       = 2'd0,
        st1_wait_a_res = 2'd1,
        st1_wait_b_res = 2'd2
    }
    state1, next_state1;

    enum logic
    {
        st2_idle       = 1'b0,
        st2_wait_c_res = 1'b1
    }
    state2, next_state2;

    logic [31:0] b_reg;

    always_ff @ (posedge clk) begin
        if(rst)
            b_reg <= '0;
        else if (arg_vld && state1 == st1_idle)
            b_reg <= b;
    end

    always_comb
    begin
        next_state1 = state1;

        case (state1)
        st1_idle       : if ( arg_vld     ) next_state1 = st1_wait_a_res ;
        st1_wait_a_res : if ( isqrt_1_y_vld ) next_state1 = st1_wait_b_res ;
        st1_wait_b_res : if ( isqrt_1_y_vld ) next_state1 = st1_idle       ;
        endcase
    end

    always_comb begin
        next_state2 = state2;
        case (state2)
            st2_idle : if(arg_vld) next_state2 = st2_wait_c_res;
            st2_wait_c_res : if(isqrt_2_y_vld) next_state2 = st2_idle;
        endcase
    end

    always_ff @ (posedge clk)
        if (rst) begin
            state1 <= st1_idle;
            state2 <= st2_idle;
        end else begin
            state1 <= next_state1;
            state2 <= next_state2;
        end

    // Datapath

    always_comb
    begin
        isqrt_1_x_vld = 1'b0;
        isqrt_1_x = '0;

        case (state1)
        st1_idle       : begin isqrt_1_x_vld = arg_vld; isqrt_1_x = a; end
        st1_wait_a_res : begin isqrt_1_x_vld = isqrt_1_y_vld; isqrt_1_x = b_reg; end
        endcase
    end

    always_comb
    begin
        isqrt_2_x = '0;
        isqrt_2_x_vld = 1'b0;

        case (state2)
        st2_idle       :begin isqrt_2_x = c; isqrt_2_x_vld = arg_vld; end
        endcase
    end

    always_ff @ (posedge clk) begin
        if(rst) 
            res_vld <= 1'b0;
        else
            res_vld <= (state1 == st1_wait_b_res && isqrt_1_y_vld && (flag || isqrt_2_y_vld));
    end

    always_ff @ (posedge clk) begin
        if(rst) begin
            res <= '0;
            flag <= 1'b0;
        end else if (arg_vld && state1 == st1_idle) begin
            res <= '0;
            flag <= 1'b0;
        end else begin
            if (isqrt_2_y_vld)
                flag <= 1'b1;
            if(isqrt_1_y_vld && isqrt_2_y_vld)
                res <= res + {16'b0, isqrt_1_y} + {16'b0, isqrt_2_y};
            else if (isqrt_1_y_vld)
                res <= res + {16'b0, isqrt_1_y};
            else if (isqrt_2_y_vld)
                res <= res + {16'b0, isqrt_2_y};
        end 
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
