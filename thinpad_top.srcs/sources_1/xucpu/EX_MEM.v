`include "MEMOp.vh"

module EX_MEM(
  input wire clk,
  input wire rst,

  input wire writeEnableEX,
  input wire [4:0] writeRegEX,
  input wire [31:0] writeDataEX,
  output reg writeEnableMEM,
  output reg [4:0] writeRegMEM,
  output reg [31:0] writeDataMEM,

  input wire [7:0] memOpEX,
  input wire [31:0] memAddressEX,
  input wire [31:0] memWriteDataEX,
  output reg [7:0] memOpMEM,
  output reg [31:0] memAddressMEM,
  output reg [31:0] memWriteDataMEM,

  output reg [31:0] lastStoreAddress,
  output reg [31:0] lastStoreData
);

  always @(posedge clk) begin
    if (rst) begin
      writeEnableMEM <= 1'b0;
      writeRegMEM <= 5'h0;
      writeDataMEM <= 32'h0;
      memOpMEM <= 3'h0;
      memAddressMEM <= 32'h0;
      memWriteDataMEM <= 32'h0;
      lastStoreAddress <= 32'h0;
      lastStoreData <= 32'h0;
    end else begin
      writeEnableMEM <= writeEnableEX;
      writeRegMEM <= writeRegEX;
      writeDataMEM <= writeDataEX;
      memOpMEM <= memOpEX;
      memAddressMEM <= memAddressEX;
      memWriteDataMEM <= memWriteDataEX;
      case (memOpEX)
        `MEM_SB: begin
          lastStoreAddress <= memAddressEX;
          case (memAddressEX[1:0])
            2'b00: lastStoreData <= {24'h0, memWriteDataEX[7:0]};
            2'b01: lastStoreData <= {16'h0, memWriteDataEX[7:0], 8'h0};
            2'b10: lastStoreData <= {8'h0, memWriteDataEX[7:0], 16'h0};
            2'b11: lastStoreData <= {memWriteDataEX[7:0], 24'h0};
            default: lastStoreData <= lastStoreData;
          endcase
        end
        `MEM_SW: begin
          lastStoreAddress <= memAddressEX;
          lastStoreData <= memWriteDataEX;
        end
        default: begin
          lastStoreAddress <= lastStoreAddress;
          lastStoreData <= lastStoreData;
        end
      endcase
    end
  end

endmodule
