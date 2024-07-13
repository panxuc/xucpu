`include "OpCode.vh"
`include "ALUOp.vh"
`include "MEMOp.vh"

module ID(
  input wire clk,
  input wire rst,
  input wire [31:0] pc,
  input wire [31:0] instr,

  output reg branch,
  output reg [31:0] branchAddress,

  output reg readEnable1,
  output reg [4:0] readReg1,
  input wire [31:0] readData1,
  output reg readEnable2,
  output reg [4:0] readReg2,
  input wire [31:0] readData2,
  output reg writeEnable,
  output reg [4:0] writeReg,
  output reg [31:0] writeData,

  input wire writeEnableEX,
  input wire [4:0] writeRegEX,
  input wire [31:0] writeDataEX,
  input wire writeEnableMEM,
  input wire [4:0] writeRegMEM,
  input wire [31:0] writeDataMEM,

  output reg [7:0] memOp,
  output reg [31:0] memWriteData,

  output reg [31:0] busA,
  output reg [31:0] busB,
  output reg [7:0] aluOp,
  output reg [1:0] aluDst,

  input wire flush,
  input wire [7:0] memOpEX,
  input wire [31:0] memAddressEX,
  input wire [31:0] lastStoreAddress,
  input wire [31:0] lastStoreData,

  output wire stallReq
);

  wire [16:0] opcode17 = instr[31:15]; // ADD_W, SUB_W, OR, AND, XOR, SRLI_W, SLLI_W, SRL_W
  wire [9:0] opcode10 = instr[31:22]; // ADDI_W, ORI, ANDI, ST_W, LD_W, ST_B, LD_B, SLTI
  wire [6:0] opcode7 = instr[31:25]; // LU12I_W, PCADDU12I
  wire [5:0] opcode6 = instr[31:26]; // JIRL, B, BEQ, BNE, BL
  wire [4:0] rk = instr[14:10];
  wire [4:0] rj = instr[9:5];
  wire [4:0] rd = instr[4:0];
  wire [4:0] ui5 = instr[14:10];
  wire [11:0] si12 = instr[21:10];
  wire [19:0] si20 = instr[24:5];
  wire [15:0] offs16 = instr[25:10];
  wire [25:0] offs26 = {instr[9:0], instr[25:10]};

  wire [31:0] signExtend12 = {{20{si12[11]}}, si12[11:0]};
  wire [31:0] zeroExtend12 = {20'b0, si12[11:0]};
  wire [31:0] signExtend16 = {{14{offs16[15]}}, offs16[15:0], 2'b00};
  wire [31:0] signExtend20 = {si20[19:0], 12'b0};
  wire [31:0] dontExtend20 = {si20[19:0], 12'b0};
  wire [31:0] signExtend26 = {{4{offs26[25]}}, offs26[25:0], 2'b00};

  wire lastInstrLoad = memOpEX == `MEM_LW || memOpEX == `MEM_LB;

  reg [31:0] branchReg1;
  reg [31:0] branchReg2;

  reg stallReqReg1;
  reg stallReqReg2;

  always @(*) begin
    if (rst || flush) begin
      branch = 1'b0;
      branchAddress = 32'h0;
      readEnable1 = 1'b0;
      readReg1 = 5'h0;
      readEnable2 = 1'b0;
      readReg2 = 5'h0;
      writeEnable = 1'b0;
      writeReg = 5'h0;
      writeData = 32'h0;
      memOp = 3'b0;
      memWriteData = 32'h0;
      busA = 32'h0;
      busB = 32'h0;
      aluOp = 3'h0;
      aluDst = 2'b0;
      branchReg1 = 32'h0;
      branchReg2 = 32'h0;
      stallReqReg1 = 1'b0;
      stallReqReg2 = 1'b0;
    end else begin
      branch = 1'b0;
      branchAddress = 32'h0;
      readEnable1 = 1'b0;
      readReg1 = 5'h0;
      readEnable2 = 1'b0;
      readReg2 = 5'h0;
      writeEnable = 1'b0;
      writeReg = 5'h0;
      writeData = 32'h0;
      memOp = 3'b0;
      memWriteData = 32'h0;
      busA = 32'h0;
      busB = 32'h0;
      aluOp = 3'h0;
      aluDst = 2'b0;
      branchReg1 = 32'h0;
      branchReg2 = 32'h0;
      stallReqReg1 = 1'b0;
      stallReqReg2 = 1'b0;
      case (opcode6)
        `JIRL: begin
          writeEnable = 1'b1;
          writeReg = rd;
          writeData = pc + 4;
          readEnable1 = 1'b1;
          readReg1 = rj;
          branchReg1 = readData1;
          if (lastInstrLoad && readReg1 == writeRegEX) begin
            stallReqReg1 = 1'b1;
          end else if (writeEnableEX && readReg1 == writeRegEX) begin
            branchReg1 = writeDataEX;
          end else if (writeEnableMEM && readReg1 == writeRegMEM) begin
            branchReg1 = writeDataMEM;
          end
          if (~stallReqReg1) begin
            branch = 1'b1;
            branchAddress = branchReg1 + signExtend16;
          end
        end
        `B: begin
          branch = 1'b1;
          branchAddress = pc + signExtend26;
        end
        `BEQ: begin
          readEnable1 = 1'b1;
          readReg1 = rj;
          readEnable2 = 1'b1;
          readReg2 = rd;
          branchReg1 = readData1;
          branchReg2 = readData2;
          if (lastInstrLoad && readReg1 == writeRegEX) begin
            stallReqReg1 = 1'b1;
          end else if (writeEnableEX && readReg1 == writeRegEX) begin
            branchReg1 = writeDataEX;
          end else if (writeEnableMEM && readReg1 == writeRegMEM) begin
            branchReg1 = writeDataMEM;
          end
          if (lastInstrLoad && readReg2 == writeRegEX) begin
            stallReqReg2 = 1'b1;
          end else if (writeEnableEX && readReg2 == writeRegEX) begin
            branchReg2 = writeDataEX;
          end else if (writeEnableMEM && readReg2 == writeRegMEM) begin
            branchReg2 = writeDataMEM;
          end
          if (~stallReqReg1 && ~stallReqReg2 && branchReg1 == branchReg2) begin
            branch = 1'b1;
            branchAddress = pc + signExtend16;
          end
        end
        `BNE: begin
          readEnable1 = 1'b1;
          readReg1 = rj;
          readEnable2 = 1'b1;
          readReg2 = rd;
          branchReg1 = readData1;
          branchReg2 = readData2;
          if (lastInstrLoad && readReg1 == writeRegEX) begin
            stallReqReg1 = 1'b1;
          end else if (writeEnableEX && readReg1 == writeRegEX) begin
            branchReg1 = writeDataEX;
          end else if (writeEnableMEM && readReg1 == writeRegMEM) begin
            branchReg1 = writeDataMEM;
          end
          if (lastInstrLoad && readReg2 == writeRegEX) begin
            stallReqReg2 = 1'b1;
          end else if (writeEnableEX && readReg2 == writeRegEX) begin
            branchReg2 = writeDataEX;
          end else if (writeEnableMEM && readReg2 == writeRegMEM) begin
            branchReg2 = writeDataMEM;
          end
          if (~stallReqReg1 && ~stallReqReg2 && branchReg1 != branchReg2) begin
            branch = 1'b1;
            branchAddress = pc + signExtend16;
          end
        end
        `BL: begin
          branch = 1'b1;
          branchAddress = pc + signExtend26;
          writeEnable = 1'b1;
          writeReg = 5'h1;
          writeData = pc + 4;
        end
        `BLTU: begin
          readEnable1 = 1'b1;
          readReg1 = rj;
          readEnable2 = 1'b1;
          readReg2 = rd;
          branchReg1 = readData1;
          branchReg2 = readData2;
          if (lastInstrLoad && readReg1 == writeRegEX) begin
            stallReqReg1 = 1'b1;
          end else if (writeEnableEX && readReg1 == writeRegEX) begin
            branchReg1 = writeDataEX;
          end else if (writeEnableMEM && readReg1 == writeRegMEM) begin
            branchReg1 = writeDataMEM;
          end
          if (lastInstrLoad && readReg2 == writeRegEX) begin
            stallReqReg2 = 1'b1;
          end else if (writeEnableEX && readReg2 == writeRegEX) begin
            branchReg2 = writeDataEX;
          end else if (writeEnableMEM && readReg2 == writeRegMEM) begin
            branchReg2 = writeDataMEM;
          end
          if (~stallReqReg1 && ~stallReqReg2 && $unsigned(branchReg1) < $unsigned(branchReg2)) begin
            branch = 1'b1;
            branchAddress = pc + signExtend16;
          end
        end
        default: begin
          case (opcode7)
            `LU12I_W: begin
              writeEnable = 1'b1;
              writeReg = rd;
              writeData = dontExtend20;
            end
            `PCADDU12I: begin
              writeEnable = 1'b1;
              writeReg = rd;
              busA = pc;
              busB = signExtend20;
              aluOp = `ALU_ADD;
              aluDst = `DST_REG;
            end
            default: begin
              case (opcode10)
                `ADDI_W: begin
                  writeEnable = 1'b1;
                  writeReg = rd;
                  readEnable1 = 1'b1;
                  readReg1 = rj;
                  busA = readData1;
                  busB = signExtend12;
                  aluOp = `ALU_ADD;
                  aluDst = `DST_REG;
                end
                `ORI: begin
                  writeEnable = 1'b1;
                  writeReg = rd;
                  readEnable1 = 1'b1;
                  readReg1 = rj;
                  busA = readData1;
                  busB = zeroExtend12;
                  aluOp = `ALU_OR;
                  aluDst = `DST_REG;
                end
                `ANDI: begin
                  writeEnable = 1'b1;
                  writeReg = rd;
                  readEnable1 = 1'b1;
                  readReg1 = rj;
                  busA = readData1;
                  busB = zeroExtend12;
                  aluOp = `ALU_AND;
                  aluDst = `DST_REG;
                end
                `ST_W: begin
                  readEnable1 = 1'b1;
                  readReg1 = rj;
                  readEnable2 = 1'b1;
                  readReg2 = rd;
                  memOp = `MEM_SW;
                  memWriteData = readData2[31:0];
                  busA = readData1;
                  busB = signExtend12;
                  aluOp = `ALU_ADD;
                  aluDst = `DST_MEM;
                end
                `LD_W: begin
                  writeEnable = 1'b1;
                  writeReg = rd;
                  readEnable1 = 1'b1;
                  readReg1 = rj;
                  memOp = `MEM_LW;
                  busA = readData1;
                  busB = signExtend12;
                  aluOp = `ALU_ADD;
                  aluDst = `DST_MEM;
                end
                `ST_B: begin
                  readEnable1 = 1'b1;
                  readReg1 = rj;
                  readEnable2 = 1'b1;
                  readReg2 = rd;
                  memOp = `MEM_SB;
                  memWriteData = readData2[7:0];
                  busA = readData1;
                  busB = signExtend12;
                  aluOp = `ALU_ADD;
                  aluDst = `DST_MEM;
                end
                `LD_B: begin
                  writeEnable = 1'b1;
                  writeReg = rd;
                  readEnable1 = 1'b1;
                  readReg1 = rj;
                  memOp = `MEM_LB;
                  busA = readData1;
                  busB = signExtend12;
                  aluOp = `ALU_ADD;
                  aluDst = `DST_MEM;
                end
                `SLTI: begin
                  writeEnable = 1'b1;
                  writeReg = rd;
                  readEnable1 = 1'b1;
                  readReg1 = rj;
                  busA = readData1;
                  busB = signExtend12;
                  aluOp = `ALU_SLT;
                  aluDst = `DST_REG;
                end
                default: begin
                  case (opcode17)
                    `ADD_W: begin
                      writeEnable = 1'b1;
                      writeReg = rd;
                      readEnable1 = 1'b1;
                      readReg1 = rj;
                      readEnable2 = 1'b1;
                      readReg2 = rk;
                      busA = readData1;
                      busB = readData2;
                      aluOp = `ALU_ADD;
                      aluDst = `DST_REG;
                    end
                    `SUB_W: begin
                      writeEnable = 1'b1;
                      writeReg = rd;
                      readEnable1 = 1'b1;
                      readReg1 = rj;
                      readEnable2 = 1'b1;
                      readReg2 = rk;
                      busA = readData1;
                      busB = readData2;
                      aluOp = `ALU_SUB;
                      aluDst = `DST_REG;
                    end
                    `OR: begin
                      writeEnable = 1'b1;
                      writeReg = rd;
                      readEnable1 = 1'b1;
                      readReg1 = rj;
                      readEnable2 = 1'b1;
                      readReg2 = rk;
                      busA = readData1;
                      busB = readData2;
                      aluOp = `ALU_OR;
                      aluDst = `DST_REG;
                    end
                    `AND: begin
                      writeEnable = 1'b1;
                      writeReg = rd;
                      readEnable1 = 1'b1;
                      readReg1 = rj;
                      readEnable2 = 1'b1;
                      readReg2 = rk;
                      busA = readData1;
                      busB = readData2;
                      aluOp = `ALU_AND;
                      aluDst = `DST_REG;
                    end
                    `XOR: begin
                      writeEnable = 1'b1;
                      writeReg = rd;
                      readEnable1 = 1'b1;
                      readReg1 = rj;
                      readEnable2 = 1'b1;
                      readReg2 = rk;
                      busA = readData1;
                      busB = readData2;
                      aluOp = `ALU_XOR;
                      aluDst = `DST_REG;
                    end
                    `SRLI_W: begin
                      writeEnable = 1'b1;
                      writeReg = rd;
                      readEnable1 = 1'b1;
                      readReg1 = rj;
                      busA = readData1;
                      busB = ui5;
                      aluOp = `ALU_SRL;
                      aluDst = `DST_REG;
                    end
                    `SLLI_W: begin
                      writeEnable = 1'b1;
                      writeReg = rd;
                      readEnable1 = 1'b1;
                      readReg1 = rj;
                      busA = readData1;
                      busB = ui5;
                      aluOp = `ALU_SLL;
                      aluDst = `DST_REG;
                    end
                    `MUL_W: begin
                      writeEnable = 1'b1;
                      writeReg = rd;
                      readEnable1 = 1'b1;
                      readReg1 = rj;
                      readEnable2 = 1'b1;
                      readReg2 = rk;
                      busA = readData1;
                      busB = readData2;
                      aluOp = `ALU_MUL;
                      aluDst = `DST_REG;
                    end
                    `SRL_W: begin
                      writeEnable = 1'b1;
                      writeReg = rd;
                      readEnable1 = 1'b1;
                      readReg1 = rj;
                      readEnable2 = 1'b1;
                      readReg2 = rk;
                      busA = readData1;
                      busB = readData2;
                      aluOp = `ALU_SRL;
                      aluDst = `DST_REG;
                    end
                    default: begin
                    end
                  endcase
                end
              endcase
            end
          endcase
        end
      endcase
      if (readEnable1 && lastInstrLoad && readReg1 == writeRegEX && memAddressEX == lastStoreAddress) begin
        busA = lastStoreData;
      end else if (readEnable1 && lastInstrLoad && readReg1 == writeRegEX) begin
        busA = 32'h0;
        stallReqReg1 = 1'b1;
      end else if (readEnable1 && writeEnableEX && readReg1 == writeRegEX) begin
        busA = writeDataEX;
      end else if (readEnable1 && writeEnableMEM && readReg1 == writeRegMEM) begin
        busA = writeDataMEM;
      end
      if (readEnable2 && lastInstrLoad && readReg2 == writeRegEX && memAddressEX == lastStoreAddress) begin
        busB = lastStoreData;
      end else if (readEnable2 && lastInstrLoad && readReg2 == writeRegEX) begin
        busB = 32'h0;
        stallReqReg2 = 1'b1;
      end else if (readEnable2 && writeEnableEX && readReg2 == writeRegEX) begin
        busB = writeDataEX;
      end else if (readEnable2 && writeEnableMEM && readReg2 == writeRegMEM) begin
        busB = writeDataMEM;
      end
    end
  end

  assign stallReq = stallReqReg1 || stallReqReg2;

endmodule
