//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module conv_first_to_last_no_ready
# (
    parameter width = 8
)
(
    input                clock,
    input                reset,

    input                up_valid,
    input                up_ready,
    input                up_first,
    input  [width - 1:0] up_data,

    output               down_valid,
    output               down_last,
    output [width - 1:0] down_data
);
    logic [width - 1:0] buffer;
    logic buf_id;

    assign down_data  = buffer;
    assign down_valid = buf_id && up_valid && up_ready;
    assign down_last = buf_id && up_valid && up_ready && up_first;

    always_ff @(posedge clock)
    begin
        if (reset)
        begin
            buffer <= '0;
            buf_id <= 1'b0;
        end
        else if (up_valid && up_ready)
        begin
            buffer <= up_data;
            buf_id <= 1'b1;
        end
    end
    // Task:
    // Implement a module that converts 'first' input status signal
    // to the 'last' output status signal.
    //
    // See README for full description of the task with timing diagram.


endmodule
