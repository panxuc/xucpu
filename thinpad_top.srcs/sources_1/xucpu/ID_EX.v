module ID_EX(
  input wire clk,
  input wire rst,
  input wire stall,

  input wire writeEnableID,
  input wire [4:0] writeRegID,
  input wire [31:0] writeDataID,
  output reg writeEnableEX,
  output reg [4:0] writeRegEX,
  output reg [31:0] writeDataEX,

  input wire [7:0] memOpID,
  input wire [31:0] memWriteDataID,
  output reg [7:0] memOpEX,
  output reg [31:0] memWriteDataEX,

  input wire [31:0] busAID,
  input wire [31:0] busBID,
  input wire [7:0] aluOpID,
  input wire [1:0] aluDstID,
  output reg [31:0] busAEX,
  output reg [31:0] busBEX,
  output reg [7:0] aluOpEX,
  output reg [1:0] aluDstEX
);

  always @(posedge clk) begin
    if (rst) begin
      writeEnableEX <= 1'b0;
      writeRegEX <= 5'h0;
      writeDataEX <= 32'h0;
      memOpEX <= 3'h0;
      memWriteDataEX <= 32'h0;
      busAEX <= 32'h0;
      busBEX <= 32'h0;
      aluOpEX <= 3'h0;
      aluDstEX <= 2'h0;
    end else if (stall) begin
      writeEnableEX <= 1'b0;
      writeRegEX <= 5'h0;
      writeDataEX <= 32'h0;
      memOpEX <= 3'h0;
      memWriteDataEX <= 32'h0;
      busAEX <= 32'h0;
      busBEX <= 32'h0;
      aluOpEX <= 3'h0;
      aluDstEX <= 2'h0;
    end else begin
      writeEnableEX <= writeEnableID;
      writeRegEX <= writeRegID;
      writeDataEX <= writeDataID;
      memOpEX <= memOpID;
      memWriteDataEX <= memWriteDataID;
      busAEX <= busAID;
      busBEX <= busBID;
      aluOpEX <= aluOpID;
      aluDstEX <= aluDstID;
    end
  end

endmodule
