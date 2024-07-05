module CPU(
  input wire clk,
  input wire rst,
)

  wire stall;
  wire exception;
  wire [31:0] exceptionAddress;
  wire branch;
  wire [31:0] branchAddress;
  wire [31:0] pc;

  PC u_pc(
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .exception(exception),
    .exceptionAddress(exceptionAddress),
    .branch(branch),
    .branchAddress(branchAddress),
    .pc(pc)
  );

endmodule
