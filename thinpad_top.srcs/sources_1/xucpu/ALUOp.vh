`ifndef __ALUOP_VH__
`define __ALUOP_VH__

`define ALU_ADD 8'b00000000
`define ALU_SUB 8'b00000001
`define ALU_AND 8'b00000010
`define ALU_OR  8'b00000011
`define ALU_XOR 8'b00000100
`define ALU_SLL 8'b00000101
`define ALU_SRL 8'b00000110
`define ALU_SLT 8'b00000111
`define ALU_MUL 8'b00001000

`define DST_NOP 2'b00
`define DST_REG 2'b01
`define DST_MEM 2'b10

`endif
