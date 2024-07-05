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
  output reg [31:0] memWriteDataMEM
);

  always @(posedge clk) begin
    if (rst) begin
      writeEnableMEM <= 1'b0;
      writeRegMEM <= 5'h0;
      writeDataMEM <= 32'h0;
      memOpMEM <= 3'h0;
      memAddressMEM <= 32'h0;
      memWriteDataMEM <= 32'h0;
    end else begin
      writeEnableMEM <= writeEnableEX;
      writeRegMEM <= writeRegEX;
      writeDataMEM <= writeDataEX;
      memOpMEM <= memOpEX;
      memAddressMEM <= memAddressEX;
      memWriteDataMEM <= memWriteDataEX;
    end
  end

endmodule
