module IF_ID(
  input wire clk,
  input wire rst,
  input wire stall,

  input wire [31:0] pcIF,
  input wire [31:0] instrIF,
  output reg [31:0] pcID,
  output reg [31:0] instrID
);

  always @(posedge clk) begin
    if (rst) begin
      pcID <= 32'h0;
      instrID <= 32'h0;
    end else if (stall) begin
      pcID <= pcID;
      instrID <= instrID;
    end else begin
      pcID <= pcIF;
      instrID <= instrIF;
    end
  end

endmodule
