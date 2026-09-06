//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_1_to_2_fc
# (
    parameter width = 8
)
(
    input                   clk,
    input                   rst,
    input                   up_valid,
    output                  up_ready,
    input  [   width - 1:0] up_data,
    output                  down_valid,
    output [ 2*width - 1:0] down_data,
    input                   down_ready
);
    typedef enum logic [1:0]
    {
        st_empty = 2'd0,
        st_hi = 2'd1,
        st_full = 2'd2  
    } state_t;

    state_t state, next_state;
    logic [width - 1:0] hi_reg;
    logic [width - 1:0] low_reg;
    logic up_ready_r;
    logic down_valid_r;
    logic [2 * width - 1:0] down_data_r;

    assign up_ready = up_ready_r;
    assign down_valid = down_valid_r;
    assign down_data = down_data_r;

    always_comb begin
        next_state = state;
        up_ready_r = 1'b0;
        down_valid_r = 1'b0;
        down_data_r = '0;
        case (state)
            st_empty: begin
                up_ready_r   = 1'b1;
                down_valid_r = 1'b0;
                if (up_valid)
                    next_state = st_hi;
            end
            st_hi: begin
                up_ready_r = 1'b1;
                if (up_valid) begin
                    down_valid_r = 1'b1;
                    down_data_r = {hi_reg, up_data};
                    if (down_ready)
                        next_state = st_empty; 
                    else
                        next_state = st_full;
                end else 
                    down_valid_r = 1'b0;
            end
            st_full: begin
                down_valid_r = 1'b1;
                down_data_r = {hi_reg, low_reg};
                if (down_ready) begin
                    if (up_valid) begin
                        up_ready_r = 1'b1;
                        next_state = st_hi;
                    end else begin
                        up_ready_r = 1'b1;
                        next_state = st_empty;
                    end
                end else begin
                    up_ready_r = 1'b0;
                end
            end
            default: next_state = st_empty;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= st_empty;
            hi_reg <= '0;
            low_reg <= '0;
        end else begin
            state <= next_state;
            case (state)
                st_empty: begin
                    if (up_valid && up_ready_r)
                        hi_reg <= up_data;
                end
                st_hi: begin
                    if (up_valid && !down_ready)
                        low_reg <= up_data;
                end
                st_full: begin
                    if (down_ready && up_valid)
                        hi_reg <= up_data;
                end
            endcase
        end
    end
    // Task:
    // Implement a module that generates one token from of two tokens.
    // Example:
    // "01", "10" => "0110"
    //
    // The module must use signals valid-ready for transfer tokens.


endmodule
