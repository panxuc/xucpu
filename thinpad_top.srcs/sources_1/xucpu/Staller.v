module Staller(
  input wire clk,
  input wire rst,
  input wire stallReqID,
  input wire stallReqMEM,
  output wire stall
);

  assign stall = stallReqID | stallReqMEM;

endmodule
