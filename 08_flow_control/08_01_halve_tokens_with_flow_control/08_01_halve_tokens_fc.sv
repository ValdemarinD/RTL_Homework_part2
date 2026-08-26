module halve_tokens_with_flow_control
(
    input  logic clk,
    input  logic rst,

    input  logic up_valid,
    input  logic up_token,
    output logic up_ready,

    output logic down_valid,
    output logic down_data,
    input  logic down_ready
);

    logic swit;

    assign down_valid = up_valid;
    assign down_data = up_valid && up_token && swit && down_ready;
    assign up_ready = up_valid && (!up_token || !swit || down_ready);

    always_ff @(posedge clk) begin
        if (rst) begin
            swit <= 1'b0;
        end else begin
            if (up_valid && up_ready) begin
                if (up_token)
                    swit <= !swit;
            end
        end
    end

endmodule