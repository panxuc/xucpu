module RAM(
  input wire clk,
  input wire rst,

  output wire txd,
  input wire rxd,

  input wire instrMemReadEnable,
  input wire [31:0] instrMemAddress,
  output reg [31:0] instrMemData,

  input wire dataMemReadEnable,
  input wire dataMemWriteEnable,
  output reg [31:0] dataMemReadData,
  input wire [31:0] dataMemWriteData,
  input wire [31:0] dataMemAddress
);

  parameter CLK_FREQ = 50000000;
  parameter BAUD = 9600;

  wire txdStart;
  wire [7:0] txdData;
  wire txdBusy;
  
  wire rxdDataReady;
  wire rxdClear;
  wire [7:0] rxdData;

  async_transmitter #(.ClkFrequency(CLK_FREQ), .Baud(BAUD)) u_async_transmitter(
      .clk(clk),
      .TxD_start(txdStart),
      .TxD_data(txdData),
      .TxD(txd),
      .TxD_busy(txdBusy)
    );

  async_receiver #(.ClkFrequency(CLK_FREQ), .Baud(BAUD)) u_async_receiver(
      .clk(clk),
      .RxD(rxd),
      .RxD_data_ready(rxdDataReady),
      .RxD_clear(rxdClear),
      .RxD_data(rxdData)
    );

endmodule
