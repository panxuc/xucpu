module CPU(
  input wire clk,
  input wire rst,

  output wire instrMemReadEnable,
  output wire [31:0] instrMemAddress,
  input wire [31:0] instrMemData,

  output wire dataMemReadEnable,
  output wire dataMemWriteEnable,
  input wire [31:0] dataMemReadData,
  output wire [31:0] dataMemWriteData,
  output wire [31:0] dataMemAddress
);
  // IF

  // ID
  wire IDPcIn;
  wire [31:0] IDInstrIn;

  wire IDWriteEnableOut;
  wire [4:0] IDWriteRegOut;
  wire [31:0] IDWriteDataOut;

  wire [31:0] IDBusAOut;
  wire [31:0] IDBusBOut;
  wire [7:0] IDAluOpOut;
  wire [1:0] IDAluDstOut;

  wire IDMemOpOut;
  wire [31:0] IDMemWriteDataOut;

  // EX
  wire EXWriteEnableOut;
  wire [4:0] EXWriteRegOut;
  wire [31:0] EXWriteDataIn;
  wire [31:0] EXWriteDataOut;

  wire [1:0] EXAluDstIn;

  wire EXMemOpOut;
  wire [31:0] EXMemAddressOut;
  wire [31:0] EXMemWriteDataOut;

  // MEM
  wire MEMWriteEnableIn;
  wire MEMWriteEnableOut;
  wire [4:0] MEMWriteRegIn;
  wire [4:0] MEMWriteRegOut;
  wire [31:0] MEMWriteDataIn;
  wire [31:0] MEMWriteDataOut;

  wire [7:0] MEMMemOpIn;
  wire [31:0] MEMMemAddressIn;
  wire [31:0] MEMMemWriteDataIn;

  // WB
  wire WBWriteEnableIn;
  wire [4:0] WBWriteRegIn;
  wire [31:0] WBWriteDataIn;

  // PC
  wire stall;
  wire exception;
  wire [31:0] exceptionAddress;
  wire branch;
  wire [31:0] branchAddress;
  wire [31:0] pc;

  // Reg
  wire RegReadEnable1;
  wire [4:0] RegReadReg1;
  wire [31:0] RegReadData1;
  wire RegReadEnable2;
  wire [4:0] RegReadReg2;
  wire [31:0] RegReadData2;
  wire RegWriteEnable;
  wire [4:0] RegWriteReg;
  wire [31:0] RegWriteData;

  // ALU
  wire [31:0] ALUBusA;
  wire [31:0] ALUBusB;
  wire [7:0] ALUOp;
  wire [31:0] ALUOut;

  // RAM
  wire [7:0] RAMOp;
  wire [31:0] RAMAddress;
  wire [31:0] RAMWriteData;
  wire [31:0] RAMReadData;

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

  IF_ID u_if_id(
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .pcIF(pc),
    .instrIF(IDInstrIn),
    .pcID(IDPcIn),
    .instrID(IDInstrIn)
  );

  RegFile u_regfile(
    .clk(clk),
    .rst(rst),
    .readEnable1(RegReadEnable1),
    .readReg1(RegReadReg1),
    .readData1(RegReadData1),
    .readEnable2(RegReadEnable2),
    .readReg2(RegReadReg2),
    .readData2(RegReadData2),
    .writeEnable(RegWriteEnable),
    .writeReg(RegWriteReg),
    .writeData(RegWriteData)
  );

  ID u_id(
    .clk(clk),
    .rst(rst),
    .pc(IDPcIn),
    .instr(IDInstrIn),
    .branch(branch),
    .branchAddress(branchAddress),
    .readEnable1(RegReadEnable1),
    .readReg1(RegReadReg1),
    .readData1(RegReadData1),
    .readEnable2(RegReadEnable2),
    .readReg2(RegReadReg2),
    .readData2(RegReadData2),
    .writeEnable(IDWriteEnableOut),
    .writeReg(IDWriteRegOut),
    .writeData(IDWriteDataOut),
    .writeEnableEX(EXWriteEnableOut),
    .writeRegEX(EXWriteRegOut),
    .writeDataEX(EXWriteDataOut),
    .writeEnableMEM(MEMWriteEnableOut),
    .writeRegMEM(MEMWriteRegOut),
    .writeDataMEM(MEMWriteDataOut),
    .memOp(IDMemOpOut),
    .memWriteData(IDMemWriteDataOut),
    .busA(IDBusAOut),
    .busB(IDBusBOut),
    .aluOp(IDAluOpOut),
    .aluDst(IDAluDstOut)
  );

  ID_EX u_id_ex(
    .clk(clk),
    .rst(rst),
    .writeEnableID(IDWriteEnableOut),
    .writeRegID(IDWriteRegOut),
    .writeDataID(IDWriteDataOut),
    .writeEnableEX(EXWriteEnableOut),
    .writeRegEX(EXWriteRegOut),
    .writeDataEX(EXWriteDataIn),
    .memOpID(IDMemOpOut),
    .memWriteDataID(IDMemWriteDataOut),
    .memOpEX(EXMemOpOut),
    .memWriteDataEX(EXMemWriteDataOut),
    .busAID(IDBusAOut),
    .busBID(IDBusBOut),
    .aluOpID(IDAluOpOut),
    .aluDstID(IDAluDstOut),
    .busAEX(ALUBusA),
    .busBEX(ALUBusB),
    .aluOpEX(ALUOp),
    .aluDstEX(EXAluDstIn)
  );

  ALU u_alu(
    .clk(clk),
    .rst(rst),
    .busA(ALUBusA),
    .busB(ALUBusB),
    .aluOp(ALUOp),
    .aluOut(ALUOut)
  );

  EX u_ex(
    .clk(clk),
    .rst(rst),
    .aluDst(EXAluDstIn),
    .aluOut(ALUOut),
    .writeDataIn(EXWriteDataIn),
    .writeDataOut(EXWriteDataOut),
    .memAddress(EXMemAddressOut)
  );

  EX_MEM u_ex_mem(
    .clk(clk),
    .rst(rst),
    .writeEnableEX(EXWriteEnableOut),
    .writeRegEX(EXWriteRegOut),
    .writeDataEX(EXWriteDataOut),
    .writeEnableMEM(MEMWriteEnableIn),
    .writeRegMEM(MEMWriteRegIn),
    .writeDataMEM(MEMWriteDataIn),
    .memOpEX(EXMemOpOut),
    .memAddressEX(EXMemAddressOut),
    .memWriteDataEX(EXMemWriteDataOut),
    .memOpMEM(MEMMemOpIn),
    .memAddressMEM(MEMMemAddressIn),
    .memWriteDataMEM(MEMMemWriteDataIn)
  );

  MEM u_mem(
    .clk(clk),
    .rst(rst),
    .writeDataIn(MEMWriteDataIn),
    .writeDataOut(MEMWriteDataOut),
    .memOp(MEMMemOpIn),
    .memAddress(MEMMemAddressIn),
    .memWriteData(MEMMemWriteDataIn),
    .ramOp(RAMOp),
    .ramAddress(RAMAddress),
    .ramWriteData(RAMWriteData),
    .ramReadData(RAMReadData)
  );

  MEM_WB u_mem_wb(
    .clk(clk),
    .rst(rst),
    .writeEnableMEM(MEMWriteEnableOut),
    .writeRegMEM(MEMWriteRegOut),
    .writeDataMEM(MEMWriteDataOut),
    .writeEnableWB(WBWriteEnableIn),
    .writeRegWB(WBWriteRegIn),
    .writeDataWB(WBWriteDataIn)
  );

endmodule
