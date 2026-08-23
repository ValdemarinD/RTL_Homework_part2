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
    
    logic result0, result;
    logic [2:0][FLEN - 1:0] buffer;

    assign busy = (state != st_idle);


    enum logic [2:0]
    {
        st_idle = 3'd0,
        st_res1 = 3'd1,
        st_res2 = 3'd2,
        st_res3 = 3'd3,
        st_ready = 3'd4,
        st_err = 3'd5
    }
    state, next_state;

    always_comb
    begin
        next_state = state;

        case (state)
        st_idle : if (valid_in) next_state = st_res1 ;
        st_res1 : if ( f_le_err ) next_state = st_err;
                  else next_state = st_res2 ;
        st_res2 : if ( f_le_err ) next_state = st_err;
                  else next_state = st_res3 ;
        st_res3 : if ( f_le_err ) next_state = st_err;
                  else next_state = st_ready;
        st_ready : next_state = st_idle;
        st_err : next_state = st_idle;
        endcase
    end

    always_ff @ (posedge clk) begin
        if (rst) begin
            state <= st_idle;
        end else
            state <= next_state;
    end

    always_comb begin
        f_le_a = '0;
        f_le_b = '0;

        case (state)
            st_res1 : begin
                        f_le_a = buffer[0];
                        f_le_b = buffer[1];
                      end
            st_res2 : begin
                        f_le_a = buffer[1];
                        f_le_b = buffer[2];
                      end   
            st_res3 : begin
                        f_le_a = buffer[0];
                        f_le_b = buffer[1];
                      end     
        endcase
    end

    always_ff @ (posedge clk)
    begin
        if (rst) begin 
            buffer <= '0;
            sorted <= '0;
            valid_out <= 1'b0;
            err <= 1'b0;
        end
        else begin
            valid_out <= 1'b0;
            case (state)
                st_idle : begin
                            if (valid_in) begin
                                buffer <= unsorted;
                                err <= 1'b0;
                            end
                          end
                st_res1 : begin
                            if (f_le_err)
                                err <= 1'b1;
                           else if (!f_le_res) begin
                               buffer[0] <= buffer[1];
                               buffer[1] <= buffer[0];
                           end
                         end
                st_res2 : begin
                            if (f_le_err)
                                err <= 1'b1;
                            else if (!f_le_res) begin
                                buffer[1] <= buffer[2];
                                buffer[2] <= buffer[1];
                            end
                          end  
                st_res3 : begin
                            if (f_le_err)
                                err <= 1'b1;
                            else if (!f_le_res) begin
                                buffer[0] <= buffer[1];
                                buffer[1] <= buffer[0];
                            end
                          end
                st_ready: begin 
                    sorted <= buffer;
                    valid_out <= 1'b1;
                    end   
                st_err : err <= 1'b1;
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
