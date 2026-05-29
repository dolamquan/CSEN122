`timescale 1ns/1ps
`include "scu_defines.v"

module control_unit(
    input [3:0] opcode,

    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg alu_src,

    output reg svpc,
    output reg jm,
    output reg brz,
    output reg brn,

    output reg [2:0] alu_ctl
);
    always @(*) begin
        reg_write  = 0;
        mem_read   = 0;
        mem_write  = 0;
        mem_to_reg = 0;
        alu_src    = 0;

        svpc = 0;
        jm   = 0;
        brz  = 0;
        brn  = 0;

        alu_ctl = `ALU_NOP;

        case (opcode)
            `OP_NOP: begin
                alu_ctl = `ALU_NOP;
            end

            `OP_ADD: begin
                reg_write = 1;
                alu_ctl = `ALU_ADD;
            end

            `OP_SUB: begin
                reg_write = 1;
                alu_ctl = `ALU_SUB;
            end

            `OP_NEG: begin
                reg_write = 1;
                alu_ctl = `ALU_NEG;
            end

            `OP_INC: begin
                reg_write = 1;
                alu_src = 1;
                alu_ctl = `ALU_ADD;
            end

            `OP_SVPC: begin
                reg_write = 1;
                alu_src = 1;
                svpc = 1;
                alu_ctl = `ALU_ADD;
            end

            `OP_LD: begin
                reg_write = 1;
                mem_read = 1;
                mem_to_reg = 1;
                alu_ctl = `ALU_PASS;
            end

            `OP_ST: begin
                mem_write = 1;
                alu_ctl = `ALU_PASS;
            end

            `OP_JM: begin
                mem_read = 1;
                jm = 1;
                alu_ctl = `ALU_PASS;
            end

            `OP_BRZ: begin
                brz = 1;
                alu_ctl = `ALU_PASS;
            end

            `OP_BRN: begin
                brn = 1;
                alu_ctl = `ALU_PASS;
            end

            default: begin
                alu_ctl = `ALU_NOP;
            end
        endcase
    end
endmodule