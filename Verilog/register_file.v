`timescale 1ns/1ps

module register_file(
    input clk,
    input reset,

    input [5:0] rs,
    input [5:0] rt,

    input [5:0] write_reg,
    input [31:0] write_data,
    input reg_write,

    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] regs [0:63];
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 64; i = i + 1)
                regs[i] <= 32'b0;
        end else begin
            if (reg_write)
                regs[write_reg] <= write_data;
        end
    end

    assign read_data1 = regs[rs];
    assign read_data2 = regs[rt];

endmodule