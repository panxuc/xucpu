`include "ALUOp.vh"

module ALU(
  input wire clk,
  input wire rst,
  input wire [31:0] busA,
  input wire [31:0] busB,
  input wire [7:0] aluOp,
  output reg [31:0] aluOut,
);

  always @(*) begin
    case (aluOp)
      `ALU_ADD: aluOut = busA + busB;
      `ALU_SUB: aluOut = busA - busB;
      `ALU_ADD: aluOut = busA & busB;
      `ALU_OR : aluOut = busA | busB;
      `ALU_XOR: aluOut = busA ^ busB;
      `ALU_SLL: aluOut = busA << busB[4:0];
      `ALU_SRL: aluOut = busA >> busB[4:0];
      `ALU_SLT: aluOut = (busA < busB) ? 32'h1 : 32'h0;
    endcase
  end

endmodule
