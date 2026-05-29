`timescale 1ns/1ps

module ex_mem_reg(
    input clk,
    input reset,
    input stall,
    input flush,

    input reg_write_in,
    input mem_read_in,
    input mem_write_in,
    input mem_to_reg_in,

    input jm_in,

    input [31:0] alu_result_in,
    input [31:0] write_data_in,

    input [5:0] rd_in,

    input z_in,
    input n_in,
    input updates_flags_in,

    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,

    output reg jm_out,

    output reg [31:0] alu_result_out,
    output reg [31:0] write_data_out,

    output reg [5:0] rd_out,

    output reg z_out,
    output reg n_out,
    output reg updates_flags_out
);
    always @(negedge clk or posedge reset) begin
        if (reset) begin
            reg_write_out <= 0;
            mem_read_out <= 0;
            mem_write_out <= 0;
            mem_to_reg_out <= 0;

            jm_out <= 0;

            alu_result_out <= 0;
            write_data_out <= 0;

            rd_out <= 0;

            z_out <= 0;
            n_out <= 0;
            updates_flags_out <= 0;
        end else if (!stall) begin
            if (flush) begin
                reg_write_out <= 0;
                mem_read_out <= 0;
                mem_write_out <= 0;
                mem_to_reg_out <= 0;

                jm_out <= 0;

                alu_result_out <= 0;
                write_data_out <= 0;

                rd_out <= 0;

                z_out <= 0;
                n_out <= 0;
                updates_flags_out <= 0;
            end else begin
                reg_write_out <= reg_write_in;
                mem_read_out <= mem_read_in;
                mem_write_out <= mem_write_in;
                mem_to_reg_out <= mem_to_reg_in;

                jm_out <= jm_in;

                alu_result_out <= alu_result_in;
                write_data_out <= write_data_in;

                rd_out <= rd_in;

                z_out <= z_in;
                n_out <= n_in;
                updates_flags_out <= updates_flags_in;
            end
        end
    end
endmodule