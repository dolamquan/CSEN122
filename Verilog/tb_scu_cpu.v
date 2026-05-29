`timescale 1ns/1ps
`include "scu_defines.v"

module tb_scu_cpu;

    reg clk;
    reg reset;

    scu_cpu dut(
        .clk(clk),
        .reset(reset)
    );

    // Normal instruction encoder:
    // opcode[31:28] | rd[27:22] | rs[21:16] | rt[15:10] | y[9:0]
    function [31:0] enc;
        input [3:0] op;
        input [5:0] rd;
        input [5:0] rs;
        input [5:0] rt;
        input [9:0] y;
        begin
            enc = {op, rd, rs, rt, y};
        end
    endfunction

    // SVPC encoder:
    // opcode[31:28] | rd[27:22] | imm22[21:0]
    function [31:0] enc_svpc;
        input [5:0] rd;
        input signed [21:0] imm22;
        begin
            enc_svpc = {`OP_SVPC, rd, imm22[21:0]};
        end
    endfunction

    integer i;

    // Clock: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Hold reset high at the beginning
        reset = 1;

        // Clear instruction memory to NOPs
        for (i = 0; i < 1024; i = i + 1) begin
            dut.IM.mem[i] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        end

        // ============================================================
        // Demo assembly with NOPs inserted for pipeline safety
        // ============================================================
        //
        // Adjusted label addresses:
        //
        // LABEL1 = 15
        // SKIP1  = 21
        // LABEL2 = 31
        // SKIP2  = 36
        //
        // Expected final values:
        // x1  = 100
        // x2  = 104
        // x3  = -100
        // x4  = 210
        // x5  = 100
        // x6  = 204
        // x7  = 0
        // x8  = 214
        // x9  = 95
        // Mem[100] = 100
        // ============================================================

        dut.IM.mem[0]  = enc_svpc(6'd1,  22'sd100); // x1  = 0 + 100 = 100
        dut.IM.mem[1]  = enc_svpc(6'd10, 22'sd14);  // x10 = 1 + 14  = 15 LABEL1
        dut.IM.mem[2]  = enc_svpc(6'd11, 22'sd29);  // x11 = 2 + 29  = 31 LABEL2
        dut.IM.mem[3]  = enc_svpc(6'd12, 22'sd18);  // x12 = 3 + 18  = 21 SKIP1
        dut.IM.mem[4]  = enc_svpc(6'd13, 22'sd32);  // x13 = 4 + 32  = 36 SKIP2

        dut.IM.mem[5]  = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[6]  = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);

        dut.IM.mem[7]  = enc(`OP_INC, 6'd2, 6'd1, 6'd0, 10'd4);     // INC x2, x1, 4 => x2 = 104
        dut.IM.mem[8]  = enc(`OP_NEG, 6'd3, 6'd1, 6'd0, 10'd0);     // NEG x3, x1 => x3 = -100

        dut.IM.mem[9]  = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[10] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);

        dut.IM.mem[11] = enc(`OP_BRN, 6'd0, 6'd10, 6'd0, 10'd0);    // BRN x10, branch to LABEL1
        dut.IM.mem[12] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[13] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[14] = enc(`OP_INC, 6'd2, 6'd2, 6'd0, 10'd17);    // Should not execute

        // LABEL1 at IM[15]
        dut.IM.mem[15] = enc(`OP_ADD, 6'd4, 6'd1, 6'd2, 10'd0);     // ADD x4, x1, x2 => x4 = 204

        dut.IM.mem[16] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[17] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);

        dut.IM.mem[18] = enc(`OP_BRN, 6'd0, 6'd12, 6'd0, 10'd0);    // BRN x12, should not branch
        dut.IM.mem[19] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[20] = enc(`OP_INC, 6'd4, 6'd4, 6'd0, 10'd6);     // INC x4, x4, 6 => x4 = 210

        // SKIP1 at IM[21]
        dut.IM.mem[21] = enc(`OP_ST, 6'd0, 6'd1, 6'd1, 10'd0);      // ST x1, x1 => Mem[100] = 100
        dut.IM.mem[22] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);

        dut.IM.mem[23] = enc(`OP_LD, 6'd5, 6'd1, 6'd0, 10'd0);      // LD x5, x1 => x5 = Mem[100] = 100
        dut.IM.mem[24] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[25] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);

        dut.IM.mem[26] = enc(`OP_ADD, 6'd6, 6'd1, 6'd2, 10'd0);     // ADD x6, x1, x2 => x6 = 204
        dut.IM.mem[27] = enc(`OP_SUB, 6'd7, 6'd5, 6'd1, 10'd0);     // SUB x7, x5, x1 => x7 = 0

        dut.IM.mem[28] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[29] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);

        dut.IM.mem[30] = enc(`OP_BRZ, 6'd0, 6'd11, 6'd0, 10'd0);    // BRZ x11, branch to LABEL2

        // LABEL2 at IM[31]
        dut.IM.mem[31] = enc(`OP_ADD, 6'd8, 6'd1, 6'd2, 10'd0);     // ADD x8, x1, x2 => x8 = 204
        dut.IM.mem[32] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);

        dut.IM.mem[33] = enc(`OP_BRZ, 6'd0, 6'd13, 6'd0, 10'd0);    // BRZ x13, should not branch
        dut.IM.mem[34] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[35] = enc(`OP_INC, 6'd8, 6'd8, 6'd0, 10'd10);    // INC x8, x8, 10 => x8 = 214

        // SKIP2 at IM[36]
        dut.IM.mem[36] = enc(`OP_INC, 6'd9, 6'd1, 6'd0, -10'sd5);   // INC x9, x1, -5 => x9 = 95
        dut.IM.mem[37] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[38] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);

        dut.IM.mem[39] = enc(`OP_JM, 6'd0, 6'd1, 6'd0, 10'd0);      // JM x1 => PC = Mem[100] = 100

        // Demo requirement: put this instruction at IM address 100
        dut.IM.mem[100] = enc(`OP_JM, 6'd0, 6'd1, 6'd0, 10'd0);     // JM x1 at IM[100]

        // Keep reset high long enough to reset PC, RF, DM, and buffers
        #20;
        reset = 0;

        // Run long enough for program and pipeline to finish
        #2000;

        $display("==================================");
        $display("Demo Final Values");
        $display("x1       = %0d", $signed(dut.RF.regs[1]));
        $display("x2       = %0d", $signed(dut.RF.regs[2]));
        $display("x3       = %0d", $signed(dut.RF.regs[3]));
        $display("x4       = %0d", $signed(dut.RF.regs[4]));
        $display("x5       = %0d", $signed(dut.RF.regs[5]));
        $display("x6       = %0d", $signed(dut.RF.regs[6]));
        $display("x7       = %0d", $signed(dut.RF.regs[7]));
        $display("x8       = %0d", $signed(dut.RF.regs[8]));
        $display("x9       = %0d", $signed(dut.RF.regs[9]));
        $display("Mem[100] = %0d", $signed(dut.DM.mem[100]));
        $display("PC       = %0d", $signed(dut.PC.pc));
        $display("==================================");

        if ($signed(dut.RF.regs[1])  !== 100)  $display("ERROR: x1 wrong");
        if ($signed(dut.RF.regs[2])  !== 104)  $display("ERROR: x2 wrong");
        if ($signed(dut.RF.regs[3])  !== -100) $display("ERROR: x3 wrong");
        if ($signed(dut.RF.regs[4])  !== 210)  $display("ERROR: x4 wrong");
        if ($signed(dut.RF.regs[5])  !== 100)  $display("ERROR: x5 wrong");
        if ($signed(dut.RF.regs[6])  !== 204)  $display("ERROR: x6 wrong");
        if ($signed(dut.RF.regs[7])  !== 0)    $display("ERROR: x7 wrong");
        if ($signed(dut.RF.regs[8])  !== 214)  $display("ERROR: x8 wrong");
        if ($signed(dut.RF.regs[9])  !== 95)   $display("ERROR: x9 wrong");
        if ($signed(dut.DM.mem[100]) !== 100)  $display("ERROR: Mem[100] wrong");

        $finish;
    end

endmodule