module put_in_order
# (
    parameter width    = 16,
              n_inputs = 4
)
(
    input                       clk,
    input                       rst,

    input  [ n_inputs - 1 : 0 ] up_vlds,
    input  [ n_inputs - 1 : 0 ]
           [ width    - 1 : 0 ] up_data,

    output                      down_vld,
    output [ width   - 1 : 0 ]  down_data
);

    logic [n_inputs - 1:0] gifts;
    logic [width - 1:0] data_buf[n_inputs];
    integer next_id;

    always_ff @ (posedge clk) begin
        if(rst) begin
            gifts <= '0;
            for (int i = 0; i < n_inputs; i++ )
                data_buf[i] <= '0;
            next_id <= 0;    
        end else begin
            for (int i = 0 ; i < n_inputs; i++) begin 
                if (up_vlds[i]) begin
                    gifts <= 1'b1;
                    data_buf[i] <= up_data[i];
                end
            end

            if (gifts[next_id]) begin
                gifts[next_id] <= 1'b0;
                if (next_id == n_inputs - 1)
                    next_id <= 0;
                else
                    next_id <= next_id + 1;
            end
        end
    end

    assign down_vld = gifts[next_id];
    assign down_data = data_buf[next_id];

    // Task:
    //
    // Implement a module that accepts many outputs of the computational blocks
    // and outputs them one by one in order. Input signals "up_vlds" and "up_data"
    // are coming from an array of non-pipelined computational blocks.
    // These external computational blocks have a variable latency.
    //
    // The order of incoming "up_vlds" is not determent, and the task is to
    // output "down_vld" and corresponding data in a round-robin manner,
    // one after another, in order.
    //
    // Comment:
    // The idea of the block is kinda similar to the "parallel_to_serial" block
    // from Homework 2, but here block should also preserve the output order.


endmodule
