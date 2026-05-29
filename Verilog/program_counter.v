`timescale 1ns/1ps

module program_counter(
    input clk,
    input reset,
    input stall,
    input pc_redirect_valid,
    input [31:0] pc_redirect,
    output reg [31:0] pc
);
    always @(negedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'b0;
        end else if (!stall) begin
            if (pc_redirect_valid)
                pc <= pc_redirect;
            else
                pc <= pc + 1;
        end
    end
endmodule