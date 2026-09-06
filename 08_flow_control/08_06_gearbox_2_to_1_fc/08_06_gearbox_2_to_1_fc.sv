//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_2_to_1_fc
# (
    parameter width = 8
)
(
    input                    clk,
    input                    rst,

    input                    up_valid,
    output                   up_ready,
    input   [ 2*width - 1:0] up_data,

    output                   down_valid,
    input                    down_ready,
    output  [   width - 1:0] down_data
);

    localparam st_high = 1'b0;
    localparam st_low = 1'b1;

    logic state;
    logic [width - 1:0] low_reg;

    assign up_ready = (state == st_high) ? down_ready : 1'b0;
    assign down_valid = (state == st_high) ? up_valid : 1'b1;
    assign down_data = (state == st_high) ? up_data [2 * width - 1 : width] : low_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= st_high;
            low_reg <= '0;
        end else begin
            case (state)
                st_high: begin
                    if (up_valid && down_ready) begin
                        low_reg <= up_data [width - 1 : 0];
                        state <= st_low;
                    end
                end
                st_low: begin
                    if (down_ready) begin
                        state <= st_high;
                    end
                end
            endcase
        end
    end

    // Task:
    // Implement a module that generates tokens from of one token.
    // Example:
    // "0110" => "01", "10"
    //
    // The module must use signals valid-ready for transfer tokens.


endmodule
