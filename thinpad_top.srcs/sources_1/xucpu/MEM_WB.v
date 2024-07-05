module MEM_WB(
  input wire clk,
  input wire rst,

  input wire writeEnableMEM,
  input wire [4:0] writeRegMEM,
  input wire [31:0] writeDataMEM,
  output reg writeEnableWB,
  output reg [4:0] writeRegWB,
  output reg [31:0] writeDataWB
);

  always @(posedge clk) begin
    if (rst) begin
      writeEnableWB <= 1'b0;
      writeRegWB <= 5'h0;
      writeDataWB <= 32'h0;
    end else begin
      writeEnableWB <= writeEnableMEM;
      writeRegWB <= writeRegMEM;
      writeDataWB <= writeDataMEM;
    end
  end

endmodule