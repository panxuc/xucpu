module RAM(
  input wire clk,
  input wire rst,

  output wire txd,
  input wire rxd,

  input wire [31:0] instrMemAddress,
  output reg [31:0] instrMemData,

  input wire dataMemReadEnable,
  input wire dataMemWriteEnable,
  output reg [31:0] dataMemReadData,
  input wire [31:0] dataMemWriteData,
  input wire [31:0] dataMemAddress,
  input wire [3:0] dataMemByteEnable,
  input wire dataMemChipSelect,

  //BaseRAM信号
  inout wire[31:0] base_ram_data, //BaseRAM数据，低8位与CPLD串口控制器共享
  output reg [19:0] base_ram_addr, //BaseRAM地址
  output reg [3:0] base_ram_be_n, //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
  output reg base_ram_ce_n, //BaseRAM片选，低有效
  output reg base_ram_oe_n, //BaseRAM读使能，低有效
  output reg base_ram_we_n, //BaseRAM写使能，低有效

  //ExtRAM信号
  inout wire[31:0] ext_ram_data, //ExtRAM数据
  output reg [19:0] ext_ram_addr, //ExtRAM地址
  output reg [3:0] ext_ram_be_n, //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
  output reg ext_ram_ce_n, //ExtRAM片选，低有效
  output reg ext_ram_oe_n, //ExtRAM读使能，低有效
  output reg ext_ram_we_n //ExtRAM写使能，低有效
);

  `define SERIAL_STATE 32'hBFD003FC //串口状态地址
  `define SERIAL_DATA 32'hBFD003F8 //串口数据地址

  // 串口通信

  parameter CLK_FREQ = 56000000;
  parameter BAUD = 9600;

  wire rxdDataReady;
  wire rxdClear;
  wire [7:0] rxdData;

  wire txdStart;
  wire [7:0] txdData;
  wire txdBusy;

  wire [7:0] rxdFifoDin;
  wire rxdFifoWrEn;
  reg rxdFifoRdEn;
  wire [7:0] rxdFifoDout;
  wire rxdFifoFull;
  wire rxdFifoEmpty;

  reg [7:0] txdFifoDin;
  reg txdFifoWrEn;
  wire txdFifoRdEn;
  wire [7:0] txdFifoDout;
  wire txdFifoFull;
  wire txdFifoEmpty;

  wire serialState = (dataMemAddress == `SERIAL_STATE);
  wire serialData = (dataMemAddress == `SERIAL_DATA);
  wire baseRAM = (dataMemAddress >= 32'h80000000) && (dataMemAddress < 32'h80400000);
  wire extRAM = (dataMemAddress >= 32'h80400000) && (dataMemAddress < 32'h80800000);

  reg [31:0] serialOut;
  wire [31:0] baseRAMOut;
  wire [31:0] extRAMOut;

  async_receiver #(.ClkFrequency(CLK_FREQ), .Baud(BAUD)) u_async_receiver(
    .clk(clk),
    .RxD(rxd),
    .RxD_data_ready(rxdDataReady),
    .RxD_clear(rxdClear),
    .RxD_data(rxdData)
  );

  async_transmitter #(.ClkFrequency(CLK_FREQ), .Baud(BAUD)) u_async_transmitter(
    .clk(clk),
    .TxD_start(txdStart),
    .TxD_data(txdData),
    .TxD(txd),
    .TxD_busy(txdBusy)
  );

  fifo_generator_0 u_rxd_fifo(
    .clk(clk),
    .rst(rst),
    .din(rxdFifoDin),
    .wr_en(rxdFifoWrEn),
    .rd_en(rxdFifoRdEn),
    .dout(rxdFifoDout),
    .full(rxdFifoFull),
    .empty(rxdFifoEmpty)
  );

  fifo_generator_0 u_txd_fifo(
    .clk(clk),
    .rst(rst),
    .din(txdFifoDin),
    .wr_en(txdFifoWrEn),
    .rd_en(txdFifoRdEn),
    .dout(txdFifoDout),
    .full(txdFifoFull),
    .empty(txdFifoEmpty)
  );

  assign rxdFifoWrEn = rxdDataReady;
  assign rxdClear = rxdDataReady && !rxdFifoFull;
  assign rxdFifoDin = rxdData;
  assign txdFifoRdEn = txdStart;
  assign txdStart = !txdBusy && !txdFifoEmpty;
  assign txdData = txdFifoDout;

  always @(*) begin
    if (serialState) begin
      txdFifoWrEn <= 1'b0;
      rxdFifoRdEn <= 1'b0;
      txdFifoDin <= 8'h0;
      serialOut <= {30'h0, !rxdFifoEmpty, !txdFifoFull};
    end else if (serialData) begin
      if (!dataMemWriteEnable) begin
        txdFifoWrEn <= 1'b0;
        rxdFifoRdEn <= 1'b1;
        txdFifoDin <= 8'h0;
        serialOut <= {24'h0, rxdFifoDout};
      end else begin
        txdFifoWrEn <= 1'b1;
        rxdFifoRdEn <= 1'b0;
        txdFifoDin <= dataMemWriteData[7:0];
        serialOut <= 32'h0;
      end
    end else begin
      txdFifoWrEn <= 1'b0;
      rxdFifoRdEn <= 1'b0;
      txdFifoDin <= 8'h0;
      serialOut <= 32'h0;
    end
  end

  // baseRAM

  assign base_ram_data = (baseRAM && dataMemWriteEnable) ? dataMemWriteData : 32'hzzzzzzzz;
  assign baseRAMOut = base_ram_data;

  always @(*) begin
    if (baseRAM) begin
      base_ram_addr <= dataMemAddress[21:2];
      base_ram_be_n <= ~dataMemByteEnable;
      base_ram_ce_n <= 1'b0;
      base_ram_oe_n <= ~dataMemReadEnable;
      base_ram_we_n <= ~dataMemWriteEnable;
      instrMemData <= 32'h00000000;
    end else begin
      base_ram_addr <= instrMemAddress[21:2];
      base_ram_be_n <= 4'b0000;
      base_ram_ce_n <= 1'b0;
      base_ram_oe_n <= 1'b0;
      base_ram_we_n <= 1'b1;
      instrMemData <= baseRAMOut;
    end
  end

  // extRAM

  assign ext_ram_data = (extRAM && dataMemWriteEnable) ? dataMemWriteData : 32'hzzzzzzzz;
  assign extRAMOut = ext_ram_data;

  always @(*) begin
    if (extRAM) begin
      ext_ram_addr <= dataMemAddress[21:2];
      ext_ram_be_n <= ~dataMemByteEnable;
      ext_ram_ce_n <= 1'b0;
      ext_ram_oe_n <= ~dataMemReadEnable;
      ext_ram_we_n <= ~dataMemWriteEnable;
    end else begin
      ext_ram_addr <= 20'h0;
      ext_ram_be_n <= 4'b0000;
      ext_ram_ce_n <= 1'b0;
      ext_ram_oe_n <= 1'b1;
      ext_ram_we_n <= 1'b1;
    end
  end

  // output

  always @(*) begin
    if (serialState || serialData) begin
      dataMemReadData = serialOut;
    end else if (baseRAM) begin
      case (dataMemByteEnable)
        4'b0001: dataMemReadData <= {{24{baseRAMOut[7]}}, baseRAMOut[7:0]};
        4'b0010: dataMemReadData <= {{24{baseRAMOut[15]}}, baseRAMOut[15:8]};
        4'b0100: dataMemReadData <= {{24{baseRAMOut[23]}}, baseRAMOut[23:16]};
        4'b1000: dataMemReadData <= {{24{baseRAMOut[31]}}, baseRAMOut[31:24]};
        default: dataMemReadData <= baseRAMOut;
      endcase
    end else if (extRAM) begin
      case (dataMemByteEnable)
        4'b0001: dataMemReadData <= {{24{extRAMOut[7]}}, extRAMOut[7:0]};
        4'b0010: dataMemReadData <= {{24{extRAMOut[15]}}, extRAMOut[15:8]};
        4'b0100: dataMemReadData <= {{24{extRAMOut[23]}}, extRAMOut[23:16]};
        4'b1000: dataMemReadData <= {{24{extRAMOut[31]}}, extRAMOut[31:24]};
        default: dataMemReadData <= extRAMOut;
      endcase
    end else begin
      dataMemReadData <= 32'h00000000;
    end
  end

endmodule
