//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module parallel_to_serial
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      parallel_valid,
    input        [width - 1:0] parallel_data,

    output                     busy,
    output logic               serial_valid,
    output logic               serial_data
);
    logic [3:0] counter;
    logic [7:0] buffer;
    logic busya;

    assign busy = busya;

    always_ff @ (posedge clk) begin
        if(rst) begin
            busya <= 1'b0;
            serial_valid <= 1'b0;
            counter <= 4'b0;
            buffer <= 8'b0;
        end
        else begin
            serial_valid <= 0;
            if(parallel_valid & !busya)begin
                buffer <= parallel_data;
                counter <= 4'b0;
                busya <= 1'b1;                
            end
            else if (busya) begin
                serial_data <= buffer[counter];
                serial_valid <= 1'b1;
                if (counter == 4'b0111)begin
                    busya <= 1'b0;
                    counter <= 4'b0;
                end
                else begin
                    counter <= counter + 1'b1;
                end
            end
        end
    end

    // Task:
    // Implement a module that converts multi-bit parallel value to the single-bit serial data.
    //
    // The module should accept 'width' bit input parallel data when 'parallel_valid' input is asserted.
    // At the same clock cycle as 'parallel_valid' is asserted, the module should output
    // the least significant bit of the input data. In the following clock cycles the module
    // should output all the remaining bits of the parallel_data.
    // Together with providing correct 'serial_data' value, module should also assert the 'serial_valid' output.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.


endmodule
