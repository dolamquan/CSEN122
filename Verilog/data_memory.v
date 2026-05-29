`timescale 1ns/1ps

module data_memory(
    input clk,
    input reset,

    input mem_read,
    input mem_write,

    input [31:0] addr,
    input [31:0] write_data,

    output reg [31:0] read_data
);
    reg [31:0] mem [0:1023];
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 1024; i = i + 1)
                mem[i] <= 32'b0;

            read_data <= 32'b0;
        end else begin
            if (mem_write)
                mem[addr[9:0]] <= write_data;

            if (mem_read)
                read_data <= mem[addr[9:0]];
            else
                read_data <= 32'b0;
        end
    end

endmodule