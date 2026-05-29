`ifndef SCU_DEFINES_V
`define SCU_DEFINES_V

// Opcodes
`define OP_NOP   4'b0000
`define OP_ST    4'b0011
`define OP_ADD   4'b0100
`define OP_INC   4'b0101
`define OP_NEG   4'b0110
`define OP_SUB   4'b0111
`define OP_JM    4'b1000
`define OP_BRZ   4'b1001
`define OP_BRN   4'b1011
`define OP_LD    4'b1110
`define OP_SVPC  4'b1111

// ALU controls: {ADD, NEG, SUB}
`define ALU_ADD   3'b000
`define ALU_NOP   3'b010
`define ALU_SUB   3'b101
`define ALU_NEG   3'b110
`define ALU_PASS  3'b111

`endif