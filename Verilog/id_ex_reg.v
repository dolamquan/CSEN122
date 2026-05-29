`timescale 1ns/1ps
`include "scu_defines.v"

module id_ex_reg(
    input clk,
    input reset,
    input stall,
    input flush,

    input reg_write_in,
    input mem_read_in,
    input mem_write_in,
    input mem_to_reg_in,
    input alu_src_in,

    input svpc_in,
    input jm_in,
    input brz_in,
    input brn_in,

    input [2:0] alu_ctl_in,

    input [31:0] pc_in,
    input [31:0] rd1_in,
    input [31:0] rd2_in,
    input [31:0] imm_in,

    input [5:0] rd_in,
    input [5:0] rs_in,
    input [5:0] rt_in,

    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg alu_src_out,

    output reg svpc_out,
    output reg jm_out,
    output reg brz_out,
    output reg brn_out,

    output reg [2:0] alu_ctl_out,

    output reg [31:0] pc_out,
    output reg [31:0] rd1_out,
    output reg [31:0] rd2_out,
    output reg [31:0] imm_out,

    output reg [5:0] rd_out,
    output reg [5:0] rs_out,
    output reg [5:0] rt_out
);
    always @(negedge clk or posedge reset) begin
        if (reset) begin
            reg_write_out <= 0;
            mem_read_out <= 0;
            mem_write_out <= 0;
            mem_to_reg_out <= 0;
            alu_src_out <= 0;

            svpc_out <= 0;
            jm_out <= 0;
            brz_out <= 0;
            brn_out <= 0;

            alu_ctl_out <= `ALU_NOP;

            pc_out <= 0;
            rd1_out <= 0;
            rd2_out <= 0;
            imm_out <= 0;

            rd_out <= 0;
            rs_out <= 0;
            rt_out <= 0;
        end else if (!stall) begin
            if (flush) begin
                reg_write_out <= 0;
                mem_read_out <= 0;
                mem_write_out <= 0;
                mem_to_reg_out <= 0;
                alu_src_out <= 0;

                svpc_out <= 0;
                jm_out <= 0;
                brz_out <= 0;
                brn_out <= 0;

                alu_ctl_out <= `ALU_NOP;

                pc_out <= 0;
                rd1_out <= 0;
                rd2_out <= 0;
                imm_out <= 0;

                rd_out <= 0;
                rs_out <= 0;
                rt_out <= 0;
            end else begin
                reg_write_out <= reg_write_in;
                mem_read_out <= mem_read_in;
                mem_write_out <= mem_write_in;
                mem_to_reg_out <= mem_to_reg_in;
                alu_src_out <= alu_src_in;

                svpc_out <= svpc_in;
                jm_out <= jm_in;
                brz_out <= brz_in;
                brn_out <= brn_in;

                alu_ctl_out <= alu_ctl_in;

                pc_out <= pc_in;
                rd1_out <= rd1_in;
                rd2_out <= rd2_in;
                imm_out <= imm_in;

                rd_out <= rd_in;
                rs_out <= rs_in;
                rt_out <= rt_in;
            end
        end
    end
endmodule