module PC(
  input wire clk,
  input wire rst,
  input wire stall,
  input wire branch,
  input wire [31:0] branchAddress,
  output reg [31:0] pc,
  output reg ce
);

  always @(posedge clk) begin
    if (rst) begin
      ce <= 1'b0;
    end else begin
      ce <= 1'b1;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      pc <= 32'h00000000;
    end else if (stall == 1'b0) begin
      if (branch) begin
        pc <= branchAddress;
      end else begin
        pc <= pc + 4;
      end
    end
  end

endmodule
