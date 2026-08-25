//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module one_bit_wide_circular_buffer
# (
    parameter depth = 8
)
(
    input  clk,
    input  rst,

    input  in_data,
    output out_data
);

    localparam pointer_width = $clog2 (depth);
    localparam [pointer_width - 1:0] max_ptr = pointer_width' (depth - 1);

    logic [pointer_width - 1:0] ptr;

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            ptr <= '0;
        else
            ptr <= ( ptr == max_ptr ) ? '0 : ptr + 1'b1;

    //------------------------------------------------------------------------

    logic [depth - 1:0] data;

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            data <= '0;
        else
            data [ptr] <= in_data;

    assign out_data = data [ptr];

endmodule

//----------------------------------------------------------------------------

module circular_buffer
# (
    parameter width = 8, depth = 8
)
(
    input                clk,
    input                rst,

    input  [width - 1:0] in_data,
    output [width - 1:0] out_data
);

    localparam pointer_width = $clog2 (depth);
    localparam [pointer_width - 1:0] max_ptr = pointer_width' (depth - 1);

    logic [pointer_width - 1:0] ptr;

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            ptr <= '0;
        else
            ptr <= ( ptr == max_ptr ) ? '0 : ptr + 1'b1;

    //------------------------------------------------------------------------

    logic [width - 1:0] data [0: depth - 1];

    always_ff @ (posedge clk)
        data [ptr] <= in_data;

    assign out_data  = data [ptr];

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module circular_buffer_with_valid
# (
    parameter width = 8, depth = 8
)
(
    input                clk,
    input                rst,

    input                in_valid,
    input  [width - 1:0] in_data,

    output               out_valid,
    output [width - 1:0] out_data
);

    localparam pointer_width = $clog2 (depth);
    localparam [pointer_width - 1:0] max_ptr = pointer_width' (depth - 1);

    logic [pointer_width - 1:0] wr_ptr;
    logic [pointer_width - 1:0] rd_ptr;
    logic [width - 1:0] data [0: depth - 1];
    logic flag[0:depth - 1];

    //write_point

    always_ff @ (posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= '0;
            for(int i = 0; i < depth; i++)
                data[i] <= '0;
        end
        else if(in_valid) begin
                data [wr_ptr] <= in_data;
                if ( wr_ptr == max_ptr )
                    wr_ptr <= '0 ;
                else 
                    wr_ptr <= wr_ptr + 1'b1;                            
        end
    end

    always_ff @ (posedge clk or posedge rst) begin
        if (rst) begin
            for(int i = 0; i < depth; i++)
                flag[i] <= 1'b0;
        end
        else begin
            flag[0] <= in_valid;
            for (int i = 1; i < depth; i++)
                flag[i] <= flag[i-1];                            
        end
    end

    // read_point

    always_ff @ (posedge clk or posedge rst) begin
        if (rst)
            rd_ptr <= '0;
        else if(out_valid) begin
                if ( rd_ptr == max_ptr )
                    rd_ptr <= '0 ;
                else 
                    rd_ptr <= rd_ptr + 1'b1;                            
        end
    end

    assign out_data  = data[rd_ptr];
    assign out_valid = flag[depth - 1];
    // Task:
    // Implement a variant of a circular buffer module
    // with support for valid interface. A module should move
    // the pointer only in cases of valid data transfer.


endmodule
