//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens
(
    input        clk,
    input        rst,
    input        a,
    output logic b,
    output logic overflow
);
    logic [7:0] i_count;
    logic [8:0] exit_count;
    logic swit, i_exit, i_much;

    always_ff @ (posedge clk)
    if (rst)  begin
        swit <= 1'b0;
        overflow <= 1'b0;
        i_exit <= 1'b0;
        i_much <= 1'b0;
        i_count <= 8'b0;
        exit_count <= 9'd0;
    end else begin
        if(a) begin
            if (i_count == 8'b11001000)
                overflow <= 1'b1;
            i_count <= i_count + 8'b00000001;
        end else 
            i_count <= 8'b0;

        if (a) begin
            b <= 1'b1;
            exit_count <= exit_count + 1'b1;
        end else if( exit_count > 0) begin
            b <= 1'b1;
            exit_count <= exit_count - 9'b000000001;
        end else
            b <= 1'b0;
    end

    // Task:
    // Implement a serial module that doubles each incoming token '1' two times.
    // The module should handle doubling for at least 200 tokens '1' arriving in a row.
    //
    // In case module detects more than 200 sequential tokens '1', it should assert
    // an overflow error. The overflow error should be sticky. Once the error is on,
    // the only way to clear it is by using the "rst" reset signal.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 10010011000110100001100100
    // b -> 11011011110111111001111110


endmodule
