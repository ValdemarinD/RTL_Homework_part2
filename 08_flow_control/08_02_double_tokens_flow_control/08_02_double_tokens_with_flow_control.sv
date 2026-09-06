//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens_with_flow_control
(
    input  clk,
    input  rst,

    input  up_valid,
    output up_ready,
    input  up_token,

    output down_valid,
    input  down_ready,
    output down_data
);
  
    logic [6:0]  i_count;
    logic [15:0] exit_count;

    wire token_arriving = up_valid && up_ready && up_token;
    wire token_sent = down_ready && down_data;

    assign down_valid = 1'b1;
    assign down_data = (exit_count > 16'd0) || token_arriving;
    assign up_ready = (i_count < 7'd100) && (exit_count < 16'd200);

    always_ff @(posedge clk) begin
        if (rst) begin
            i_count    <= 7'd0;
            exit_count <= 16'd0;
        end else begin
            if (down_ready) begin
                i_count <= 7'd0;
            end else if (token_arriving) begin
                if (i_count < 7'd100)
                    i_count <= i_count + 7'd1;
            end else if (up_valid && up_ready && !up_token) begin
                i_count <= 7'd0;
            end else if (!up_valid) begin
                i_count <= 7'd0;
            end
            case ({token_arriving, token_sent})
                2'b10: exit_count <= exit_count + 16'd2;
                2'b01: exit_count <= exit_count - 16'd1;
                2'b11: exit_count <= exit_count + 16'd1; 
                default: ;
            endcase
        end
    end


  // Task:
  // Implement module double input signals (tokens). The module must use signals valid-ready for
  // transfer tokens. If the module receives more than 100 sequential tokens then it must set up_ready = 0;


endmodule
