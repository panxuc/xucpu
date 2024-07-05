`include "MEMOp.vh"

module MEM(
  input wire clk,
  input wire rst,

  input wire [7:0] memOp,
  input wire [31:0] memWriteData,
  input wire [31:0] memAddress,
  output reg [31:0] memReadData,

  output reg [31:0] ramWriteData,
  output reg [31:0] ramAddress,
  input wire [31:0] ramReadData,
);

  always @(*) begin
    case (memOp)
      `MEM_LB: begin
      end
      `MEM_LW: begin
      end
      `MEM_SB: begin
      end
      `MEM_SW: begin
      end
    endcase
  end

endmodule