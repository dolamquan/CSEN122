`timescale 1ns/1ps

module instruction_memory(
    input  [31:0] addr,
    output [31:0] instr
);
    reg [31:0] mem [0:1023];

    assign instr = mem[addr[9:0]];

endmodule