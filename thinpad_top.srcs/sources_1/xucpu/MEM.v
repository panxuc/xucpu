`include "MEMOp.vh"

module MEM(
  input wire clk,
  input wire rst,

  input wire [31:0] writeDataIn,
  output reg [31:0] writeDataOut,

  input wire [7:0] memOp,
  input wire [31:0] memAddress,
  input wire [31:0] memWriteData,

  output reg [7:0] ramOp,
  output reg [31:0] ramAddress,
  output reg [31:0] ramWriteData,
  input wire [31:0] ramReadData
);

  always @(*) begin
    case (memOp)
      `MEM_LB: begin
        ramOp = `RAM_LOAD;
        ramAddress = memAddress;
        writeDataOut = ramReadData[7:0];
      end
      `MEM_LW: begin
        ramOp = `RAM_LOAD;
        ramAddress = memAddress;
        writeDataOut = ramReadData;
      end
      `MEM_SB: begin
        ramOp = `RAM_STORE;
        ramAddress = memAddress;
        ramWriteData = memWriteData[7:0];
        writeDataOut = writeDataIn;
      end
      `MEM_SW: begin
        ramOp = `RAM_STORE;
        ramAddress = memAddress;
        ramWriteData = memWriteData;
        writeDataOut = writeDataIn;
      end
    endcase
  end

endmodule