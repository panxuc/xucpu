module EX(
  input wire clk,
  input wire rst,
  
  input wire [1:0] aluDst,
  input wire [31:0] aluOut,
  input wire [31:0] writeDataIn,
  output reg [31:0] writeDataOut,
  output reg [31:0] memAddress
);

  always @(*) begin
    case (aluDst)
      `DST_REG: begin
        writeDataOut = aluOut;
        memAddress = 32'h0;
      end
      `DST_MEM: begin
        writeDataOut = writeDataIn;
        memAddress = aluOut;
      end
      default: begin
        writeDataOut = writeDataIn;
        memAddress = 32'h0;
      end
    endcase
  end

endmodule