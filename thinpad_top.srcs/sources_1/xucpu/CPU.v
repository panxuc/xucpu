module CPU(
  input wire clk,
  input wire rst,

  output wire [31:0] instrMemAddress,
  input wire [31:0] instrMemData,

  output wire dataMemReadEnable,
  output wire dataMemWriteEnable,
  input wire [31:0] dataMemReadData,
  output wire [31:0] dataMemWriteData,
  output wire [31:0] dataMemAddress,
  output wire [3:0] dataMemByteEnable,
  output wire dataMemChipSelect,

  input wire [1:0] state
);
  // IF

  // ID
  wire [31:0] IDPcIn;
  wire [31:0] IDInstrIn;

  wire IDWriteEnableOut;
  wire [4:0] IDWriteRegOut;
  wire [31:0] IDWriteDataOut;

  wire [31:0] IDBusAOut;
  wire [31:0] IDBusBOut;
  wire [7:0] IDAluOpOut;
  wire [1:0] IDAluDstOut;

  wire [7:0] IDMemOpOut;
  wire [31:0] IDMemWriteDataOut;

  // EX
  wire EXWriteEnableOut;
  wire [4:0] EXWriteRegOut;
  wire [31:0] EXWriteDataIn;
  wire [31:0] EXWriteDataOut;

  wire [1:0] EXAluDstIn;

  wire [7:0] EXMemOpOut;
  wire [31:0] EXMemAddressOut;
  wire [31:0] EXMemWriteDataOut;

  // MEM
  wire MEMWriteEnableOut;
  wire [4:0] MEMWriteRegOut;
  wire [31:0] MEMWriteDataIn;
  wire [31:0] MEMWriteDataOut;

  wire [7:0] MEMMemOpIn;
  wire [31:0] MEMMemAddressIn;
  wire [31:0] MEMMemWriteDataIn;

  // PC
  wire stall;
  wire branch;
  wire [31:0] branchAddress;

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

  // Staller
  wire stallReqID;
  wire stallReqMEM;
  wire [31:0] lastStoreAddress;
  wire [31:0] lastStoreData;

  PC u_pc(
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .branch(branch),
    .branchAddress(branchAddress),
    .pc(instrMemAddress)
  );

  IF_ID u_if_id(
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .pcIF(instrMemAddress),
    .instrIF(instrMemData),
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
    .aluDst(IDAluDstOut),
    .memOpEX(EXMemOpOut),
    .memAddressEX(EXMemAddressOut),
    .lastStoreAddress(lastStoreAddress),
    .lastStoreData(lastStoreData),
    .stallReq(stallReqID)
  );

  ID_EX u_id_ex(
    .clk(clk),
    .rst(rst),
    .stall(stall),
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
    .writeEnableMEM(MEMWriteEnableOut),
    .writeRegMEM(MEMWriteRegOut),
    .writeDataMEM(MEMWriteDataIn),
    .memOpEX(EXMemOpOut),
    .memAddressEX(EXMemAddressOut),
    .memWriteDataEX(EXMemWriteDataOut),
    .memOpMEM(MEMMemOpIn),
    .memAddressMEM(MEMMemAddressIn),
    .memWriteDataMEM(MEMMemWriteDataIn),
    .lastStoreAddress(lastStoreAddress),
    .lastStoreData(lastStoreData)
  );

  MEM u_mem(
    .clk(clk),
    .rst(rst),
    .writeDataIn(MEMWriteDataIn),
    .writeDataOut(MEMWriteDataOut),
    .memOp(MEMMemOpIn),
    .memAddress(MEMMemAddressIn),
    .memWriteData(MEMMemWriteDataIn),
    .dataMemReadEnable(dataMemReadEnable),
    .dataMemWriteEnable(dataMemWriteEnable),
    .dataMemReadData(dataMemReadData),
    .dataMemWriteData(dataMemWriteData),
    .dataMemAddress(dataMemAddress),
    .dataMemByteEnable(dataMemByteEnable),
    .dataMemChipSelect(dataMemChipSelect),
    .stallReq(stallReqMEM)
  );

  MEM_WB u_mem_wb(
    .clk(clk),
    .rst(rst),
    .writeEnableMEM(MEMWriteEnableOut),
    .writeRegMEM(MEMWriteRegOut),
    .writeDataMEM(MEMWriteDataOut),
    .writeEnableWB(RegWriteEnable),
    .writeRegWB(RegWriteReg),
    .writeDataWB(RegWriteData)
  );

  Staller u_staller(
    .clk(clk),
    .rst(rst),
    .stallReqID(stallReqID),
    .stallReqMEM(stallReqMEM),
    .stall(stall)
  );

endmodule
