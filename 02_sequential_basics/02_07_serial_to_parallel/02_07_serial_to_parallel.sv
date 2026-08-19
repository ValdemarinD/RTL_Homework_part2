//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    logic [3:0] counter;
    logic [7:0] buff;

    always_ff @ (posedge clk) begin
        if (rst) begin
            buff <= 8'b0;
            counter <= 4'b0;
            parallel_valid <= 1'b0;
        end else begin
            parallel_valid <= 1'b0;
            if (serial_valid) begin
                if (counter == 4'b0111) begin
                    parallel_valid <= 1'b1;
                    parallel_data <= {serial_data, buff[6:0]};
                    buff <= 8'b0;
                    counter <= 4'b0;
                end
                else begin
                    buff[counter] <= serial_data;
                    counter <= counter + 1'b1;
                end
            end
        end
    end
    // Task:
    // Implement a module that converts single-bit serial data to the multi-bit parallel value.
    //
    // The module should accept one-bit values with valid interface in a serial manner.
    // After accumulating 'width' bits and receiving last 'serial_valid' input,
    // the module should assert the 'parallel_valid' at the same clock cycle
    // and output 'parallel_data' value.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.


endmodule
