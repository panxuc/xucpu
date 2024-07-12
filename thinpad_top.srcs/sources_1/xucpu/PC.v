module PC(
  input wire clk,
  input wire rst,
  input wire stall,
  input wire branch,
  input wire [31:0] branchAddress,
  output reg [31:0] pc,
  output reg lastInstrBranch
);

  always @(posedge clk) begin
    if (rst) begin
      pc <= 32'h80000000;
      lastInstrBranch <= 1'b0;
    end else if (stall) begin
      pc <= pc;
      lastInstrBranch <= 1'b0;
    end else if (branch) begin
      pc <= branchAddress;
      lastInstrBranch <= 1'b1;
    end else begin
      pc <= pc + 4;
      lastInstrBranch <= 1'b0;
    end
  end

endmodule
