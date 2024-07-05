module PC(
  input wire clk,
  input wire rst,
  input wire stall,
  input wire exception,
  input wire [31:0] exceptionAddress,
  input wire branch,
  input wire [31:0] branchAddress,
  output reg [31:0] pc
);

  always @(posedge clk) begin
    if (rst) begin
      pc <= 32'h00000000;
    end else if (exception) begin
      pc <= exceptionAddress;
    end else if (stall == 1'b0) begin
      if (branch) begin
        pc <= branchAddress;
      end else begin
        pc <= pc + 4;
      end
    end
  end

endmodule
