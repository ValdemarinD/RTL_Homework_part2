//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);
    
    logic flag, result;
    logic [0:2][FLEN - 1:0] buffer;

    assign busy = (state != st_idle);


    enum logic [1:0]
    {
        st_idle = 2'd0,
        st_res2 = 2'd1,
        st_res3 = 2'd2
    }
    state, next_state;

   always_comb begin 
    next_state = state;
    case (state)
        st_idle : if (valid_in)
                    next_state = st_res2;
        st_res2 : next_state = st_res3;
        st_res3 : next_state = st_idle;
        default : next_state = st_idle;
    endcase
    end

    always_comb begin 
    case(state)
        st_idle : begin
            f_le_a = unsorted[0];
            f_le_b = unsorted[1];
        end
        st_res2 : begin
            f_le_a = buffer[1];
            f_le_b = buffer[2];
        end
        st_res3 : begin
            f_le_a = buffer[0];
            f_le_b = buffer[1];
        end
        default : begin
            f_le_a = '0;
            f_le_b = '0;
        end
    endcase
    end

    always_ff @ (posedge clk) begin
        if (rst) begin
            state <= st_idle;
            buffer <= '0;
            sorted <= '0;
            err <= 1'b0;
            valid_out <= 1'b0;
            flag <= 1'b0;
        end else begin
            state <= next_state;
            valid_out <= 1'b0;
            err <= 1'b0;
            case(state) 
                st_idle : begin
                    if (valid_in) begin
                        flag <= f_le_err;
                        buffer[0] <= f_le_res ? unsorted[0] : unsorted[1];
                        buffer[1] <= f_le_res ? unsorted[1] : unsorted[0];
                        buffer[2] <= unsorted[2];
                        end
                end
                st_res2 : begin
                    if(f_le_err | flag)
                        flag <= 1'b1;
                    else begin
                        buffer[0] <= buffer[0];
                        buffer[1] <= f_le_res ? buffer[1] : buffer[2];
                        buffer[2] <= f_le_res ? buffer[2] : buffer[1];
                    end
                end
                st_res3 : begin 
                    valid_out <= 1'b1;
                    if(f_le_err | flag)
                        err <= 1'b1;
                    else begin
                        sorted[0] <= f_le_res ? buffer[0] : buffer[1];
                        sorted[1] <= f_le_res ? buffer[1] : buffer[0];
                        sorted[2] <= buffer[2];

                    end
                end

            endcase
        end 

    end

    // The result

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.
    //
    // Requirements:
    // The solution must have latency equal to the three clock cycles.
    // The solution should use the inputs and outputs to the single "f_less_or_equal" module.
    // The solution should NOT create instances of any modules.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res1
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.



endmodule
