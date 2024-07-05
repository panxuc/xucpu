module RegFile(
  input wire clk,
  input wire rst,
  input wire readEnable1,
  input wire [4:0] readReg1,
  output reg [31:0] readData1,
  input wire readEnable2,
  input wire [4:0] readReg2,
  output reg [31:0] readData2,
  input wire writeEnable,
  input wire [4:0] writeReg,
  input wire [31:0] writeData
);

  reg [31:0] rfData[31:0];

  integer i;

  always @(posedge clk) begin
    if (rst) begin
      for (i = 0; i < 32; i = i + 1) begin
        rfData[i] = 32'h0;
      end
    end else if (writeEnable) begin
      if (writeReg != 5'h0) begin
        rfData[writeReg] = writeData;
      end
    end
  end

  always @(*) begin
    if (rst) begin
      readData1 = 32'h0;
    end else if (readReg1 == 5'h0) begin
      readData1 = 32'h0;
    end else if (writeEnable && readReg1 == writeReg) begin
      readData1 = writeData;
    end else begin
      readData1 = rfData[readReg1];
    end
  end

  always @(*) begin
    if (rst) begin
      readData2 = 32'h0;
    end else if (readReg2 == 5'h0) begin
      readData2 = 32'h0;
    end else if (writeEnable && readReg2 == writeReg) begin
      readData2 = writeData;
    end else begin
      readData2 = rfData[readReg2];
    end
  end

endmodule
