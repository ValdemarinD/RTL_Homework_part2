//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_1_to_2
# (
    parameter width = 0
)
(
    input                    clk,
    input                    rst,

    input                    up_vld,    // upstream
    input  [    width - 1:0] up_data,

    output                   down_vld,  // downstream
    output [2 * width - 1:0] down_data
);


    logic swit, ready_or_not;
    logic [width - 1 : 0] queue;
    logic [2 * width - 1:0] que_out;

    assign down_data = que_out;
    assign down_vld = swit;

    always_ff @ (posedge clk) begin
        if(rst) begin
            swit <= 1'b0;
            queue <= '0;
            que_out <= '0;
            ready_or_not <= 1'b0;
        end 
        swit <= 1'b0;
        if(up_vld) begin
            if(ready_or_not == 1'b0) begin
                queue <= up_data;
                ready_or_not <= 1'b1;
            end
        else if(ready_or_not == 1'b1) begin
                swit <= 1'b1;
                que_out <= {queue, up_data};
                ready_or_not <= 1'b0;
            end
        end
    end

    // Task:
    // Implement a module that transforms a stream of data
    // from 'width' to the 2*'width' data width.
    //
    // The module should be capable to accept new data at each
    // clock cycle and produce concatenated 'down_data'
    // at each second clock cycle.
    //
    // The module should work properly with reset 'rst'
    // and valid 'vld' signals


endmodule
