`include "MEMOp.vh"

module MEM(
  input wire clk,
  input wire rst,

  input wire [31:0] writeDataIn,
  output reg [31:0] writeDataOut,

  input wire [7:0] memOp,
  input wire [31:0] memAddress,
  input wire [31:0] memWriteData,

  output reg dataMemReadEnable,
  output reg dataMemWriteEnable,
  input wire [31:0] dataMemReadData,
  output reg [31:0] dataMemWriteData,
  output reg [31:0] dataMemAddress,
  output reg [3:0] dataMemByteEnable,
  output reg dataMemChipSelect
);

  always @(*) begin
    case (memOp)
      `MEM_LB: begin
        writeDataOut = dataMemReadData[7:0];
        dataMemReadEnable = 1'b1;
        dataMemWriteEnable = 1'b0;
        dataMemWriteData = 32'h0;
        dataMemAddress = memAddress;
        case (memAddress[1:0])
          2'b00: dataMemByteEnable = 4'b0001;
          2'b01: dataMemByteEnable = 4'b0010;
          2'b10: dataMemByteEnable = 4'b0100;
          2'b11: dataMemByteEnable = 4'b1000;
          default: dataMemByteEnable = 4'b0000;
        endcase
        dataMemChipSelect = 1'b1;
      end
      `MEM_LW: begin
        writeDataOut = dataMemReadData;
        dataMemReadEnable = 1'b1;
        dataMemWriteEnable = 1'b0;
        dataMemWriteData = 32'h0;
        dataMemAddress = memAddress;
        dataMemByteEnable = 4'b1111;
        dataMemChipSelect = 1'b1;
      end
      `MEM_SB: begin
        writeDataOut = 32'h0;
        dataMemReadEnable = 1'b0;
        dataMemWriteEnable = 1'b1;
        dataMemWriteData = memWriteData[7:0];
        dataMemAddress = memAddress;
        case (memAddress[1:0])
          2'b00: dataMemByteEnable = 4'b0001;
          2'b01: dataMemByteEnable = 4'b0010;
          2'b10: dataMemByteEnable = 4'b0100;
          2'b11: dataMemByteEnable = 4'b1000;
          default: dataMemByteEnable = 4'b0000;
        endcase
        dataMemChipSelect = 1'b1;
      end
      `MEM_SW: begin
        writeDataOut = 32'h0;
        dataMemReadEnable = 1'b0;
        dataMemWriteEnable = 1'b1;
        dataMemWriteData = memWriteData;
        dataMemAddress = memAddress;
        dataMemByteEnable = 4'b1111;
        dataMemChipSelect = 1'b1;
      end
    endcase
  end

endmodule