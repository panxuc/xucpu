`ifndef __OPCODE_VH__
`define __OPCODE_VH__

`define ADDI_W    10'b0000001010
`define ADD_W     17'b00000000000100000
`define SUB_W     17'b00000000000100010
`define LU12I_W    7'b0001010
`define PCADDU12I  7'b0001110
`define OR        17'b00000000000101010
`define ORI       10'b0000001110
`define ANDI      10'b0000001101
`define AND       17'b00000000000101001
`define XOR       17'b00000000000101011
`define SRLI_W    17'b00000000010001001
`define SLLI_W    17'b00000000010000001
`define JIRL       6'b010011
`define B          6'b010100
`define BEQ        6'b010110
`define BNE        6'b010111
`define BL         6'b010101
`define ST_W      10'b0010100110
`define LD_W      10'b0010100010
`define ST_B      10'b0010100100
`define LD_B      10'b0010100000
`define MUL_W     17'b00000000000111000

`define SLTI      10'b0000001000
`define SRL_W     17'b00000000000101111
`define BLTU       6'b011010

`endif
