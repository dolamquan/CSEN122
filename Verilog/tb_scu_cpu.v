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
        reset = 1;

        // Clear instruction memory to NOPs
        for (i = 0; i < 1024; i = i + 1) begin
            dut.IM.mem[i] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        end

        // ============================================================
        // Updated demo program for ID-stage branch resolution
        // ============================================================
        //
        // Final label addresses:
        //
        // LABEL1 = 15
        // SKIP1  = 21
        // LABEL2 = 31
        // SKIP2  = 37
        //
        // Because SVPC does:
        // R[rd] = PC + immediate
        //
        // Therefore:
        // PC 1: x10 = 1 + 14 = 15
        // PC 2: x11 = 2 + 29 = 31
        // PC 3: x12 = 3 + 18 = 21
        // PC 4: x13 = 4 + 33 = 37
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

        dut.IM.mem[0]  = enc_svpc(6'd1,  22'sd100);              // x1 = 100
        dut.IM.mem[1]  = enc_svpc(6'd10, 22'sd14);               // x10 = LABEL1 = 15
        dut.IM.mem[2]  = enc_svpc(6'd11, 22'sd29);               // x11 = LABEL2 = 31
        dut.IM.mem[3]  = enc_svpc(6'd12, 22'sd18);               // x12 = SKIP1  = 21
        dut.IM.mem[4]  = enc_svpc(6'd13, 22'sd33);               // x13 = SKIP2  = 37

        dut.IM.mem[5]  = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[6]  = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);

        dut.IM.mem[7]  = enc(`OP_INC, 6'd2, 6'd1, 6'd0, 10'd4);  // x2 = x1 + 4 = 104
        dut.IM.mem[8]  = enc(`OP_NEG, 6'd3, 6'd1, 6'd0, 10'd0);  // x3 = -x1 = -100

        dut.IM.mem[9]  = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[10] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);

        dut.IM.mem[11] = enc(`OP_BRN, 6'd0, 6'd10, 6'd0, 10'd0); // branch to LABEL1
        dut.IM.mem[12] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[13] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[14] = enc(`OP_INC, 6'd2, 6'd2, 6'd0, 10'd17); // should not execute

        // LABEL1 = 15
        dut.IM.mem[15] = enc(`OP_ADD, 6'd4, 6'd1, 6'd2, 10'd0);  // x4 = x1 + x2 = 204

        dut.IM.mem[16] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[17] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);

        dut.IM.mem[18] = enc(`OP_BRN, 6'd0, 6'd12, 6'd0, 10'd0); // should not branch
        dut.IM.mem[19] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[20] = enc(`OP_INC, 6'd4, 6'd4, 6'd0, 10'd6);  // x4 = 210

        // SKIP1 = 21
        dut.IM.mem[21] = enc(`OP_ST, 6'd0, 6'd1, 6'd1, 10'd0);   // Mem[x1] = x1 = Mem[100] = 100
        dut.IM.mem[22] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);

        dut.IM.mem[23] = enc(`OP_LD, 6'd5, 6'd1, 6'd0, 10'd0);   // x5 = Mem[x1] = 100
        dut.IM.mem[24] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[25] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);

        dut.IM.mem[26] = enc(`OP_ADD, 6'd6, 6'd1, 6'd2, 10'd0);  // x6 = x1 + x2 = 204
        dut.IM.mem[27] = enc(`OP_SUB, 6'd7, 6'd5, 6'd1, 10'd0);  // x7 = x5 - x1 = 0

        dut.IM.mem[28] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[29] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);

        dut.IM.mem[30] = enc(`OP_BRZ, 6'd0, 6'd11, 6'd0, 10'd0); // branch to LABEL2

        // LABEL2 = 31
        dut.IM.mem[31] = enc(`OP_ADD, 6'd8, 6'd1, 6'd2, 10'd0);  // x8 = x1 + x2 = 204

        // Extra NOP added because branch is now resolved in ID stage.
        // This gives ADD x8 enough time to update the Zero flag before BRZ checks it.
        dut.IM.mem[32] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[33] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);

        dut.IM.mem[34] = enc(`OP_BRZ, 6'd0, 6'd13, 6'd0, 10'd0); // should not branch
        dut.IM.mem[35] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[36] = enc(`OP_INC, 6'd8, 6'd8, 6'd0, 10'd10); // x8 = 214

        // SKIP2 = 37
        dut.IM.mem[37] = enc(`OP_INC, 6'd9, 6'd1, 6'd0, -10'sd5); // x9 = x1 - 5 = 95
        dut.IM.mem[38] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);
        dut.IM.mem[39] = enc(`OP_NOP, 6'd0, 6'd0, 6'd0, 10'd0);

        dut.IM.mem[40] = enc(`OP_JM, 6'd0, 6'd1, 6'd0, 10'd0);   // PC = Mem[x1] = Mem[100] = 100

        // Demo requirement: put JM x1 at instruction memory address 100
        dut.IM.mem[100] = enc(`OP_JM, 6'd0, 6'd1, 6'd0, 10'd0);

        // Reset
        #20;
        reset = 0;

        // Run long enough for program to finish
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