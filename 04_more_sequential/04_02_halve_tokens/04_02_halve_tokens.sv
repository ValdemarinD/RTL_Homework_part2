//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module halve_tokens
(
    input  clk,
    input  rst,
    input  a,
    output b
);

    logic swit, outp;
    assign b = outp;

    always_ff @ (posedge clk) begin
        if(rst) begin
            swit <= 1'b0;
            outp <= 1'b0;
        end else begin
            outp <= 1'b0;
            if (a == 1'b1)
                swit <= 1'b1;
            if ((swit == 1'b1) & (a == 1'b1)) begin
                swit <= 1'b0;
                outp <= 1'b1;
            end
        end
    end
    
    // Task:
    // Implement a serial module that reduces amount of incoming '1' tokens by half.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 110_011_101_000_1111
    // b -> 010_001_001_000_0101


endmodule
