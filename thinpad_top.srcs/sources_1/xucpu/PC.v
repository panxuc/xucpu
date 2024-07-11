module PC(
  input wire clk,
  input wire rst,
  input wire stall,
  input wire branch,
  input wire [31:0] branchAddress,
  output reg [31:0] pc
);

  always @(posedge clk) begin
    if (rst) begin
      pc <= 32'h80000000;
    end else if (stall) begin
      pc <= pc;
    end else if (branch) begin
      pc <= branchAddress;
    end else begin
      pc <= pc + 4;
    end
  end

endmodule
