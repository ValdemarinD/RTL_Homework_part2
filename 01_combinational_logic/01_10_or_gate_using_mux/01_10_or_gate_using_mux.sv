//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux
(
  input  d0, d1,
  input  sel,
  output y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module or_gate_using_mux
(
    input  a,
    input  b,
    output o
);
  assign o = a ? (b ? 1'b1 : 1'b1) : (b ? 1'b1 : 1'b0);
  // Task:

  // Implement or gate using instance(s) of mux,
  // constants 0 and 1, and wire connections


endmodule
