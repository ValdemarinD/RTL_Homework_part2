//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module signed_add_with_saturation
(
  input  [3:0] a, b,
  output [3:0] sum
);
  logic [3:0] sum_int;
  assign sum = sum_int;

  always_comb begin
    sum_int = a + b;
    if ((a[3] == b[3]) && (sum_int[3] != a[3])) begin
        if (sum_int[3] == 1'b0)
          sum_int = 4'b1000;
        else
          sum_int = 4'b0111;
    end
  end

  // Task:
  //
  // Implement a module that adds two signed numbers with saturation.
  //
  // "Adding with saturation" means:
  //
  // When the result does not fit into 4 bits,
  // and the arguments are positive,
  // the sum should be set to the maximum positive number.
  //
  // When the result does not fit into 4 bits,
  // and the arguments are negative,
  // the sum should be set to the minimum negative number.


endmodule
