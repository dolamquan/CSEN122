`timescale 1ns/1ps
`include "scu_defines.v"

module scu_alu(
    input  [31:0] A,
    input  [31:0] B,
    input  [2:0]  alu_ctl,
    output reg [31:0] OUT,
    output Z,
    output N
);
    always @(*) begin
        case (alu_ctl)
            `ALU_ADD:  OUT = A + B;
            `ALU_SUB:  OUT = A - B;
            `ALU_NEG:  OUT = -A;
            `ALU_PASS: OUT = A;
            default:   OUT = 32'b0;
        endcase
    end

    assign Z = (OUT == 32'b0);
    assign N = OUT[31];

endmodule