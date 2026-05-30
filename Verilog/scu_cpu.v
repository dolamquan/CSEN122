`timescale 1ns/1ps
`include "scu_defines.v"

module scu_cpu(
    input clk,
    input reset
);

    // ============================================================
    // IF STAGE
    // ============================================================

    wire [31:0] pc; // Current program counter address 
    wire [31:0] instr_f; // Instruction fetched from instruction memory

    wire stall_pipeline;
    assign stall_pipeline = 1'b0; // No stall --> depends only on forwarding + NOPs + Flush

    wire pc_redirect_valid;  // Flag to tell if branching has occured 
    wire [31:0] pc_redirect;

    program_counter PC(
        .clk(clk),
        .reset(reset),
        .stall(stall_pipeline),
        .pc_redirect_valid(pc_redirect_valid),
        .pc_redirect(pc_redirect),
        .pc(pc)
    );

    instruction_memory IM(
        .addr(pc),
        .instr(instr_f)
    );

    // ============================================================
    // IF/ID REGISTER
    // ============================================================

    wire [31:0] ifid_pc; // Carries the PC value after it has been saved inside the IF/ID register
    wire [31:0] ifid_instr; // Carries instruction after it has been saved inside the IF/ID register

    wire flush_ifid; // Flush

    if_id_reg IF_ID(
        .clk(clk),
        .reset(reset),
        .stall(stall_pipeline),
        .flush(flush_ifid),
        .pc_in(pc),
        .instr_in(instr_f),
        .pc_out(ifid_pc),
        .instr_out(ifid_instr)
    );

    // ============================================================
    // ID STAGE
    // ============================================================

    wire [3:0] id_opcode = ifid_instr[31:28]; 
    wire [5:0] id_rd     = ifid_instr[27:22];
    wire [5:0] id_rs     = ifid_instr[21:16];
    wire [5:0] id_rt     = ifid_instr[15:10];

    wire [31:0] imm10 = {{22{ifid_instr[9]}}, ifid_instr[9:0]}; 
    wire [31:0] imm22 = {{10{ifid_instr[21]}}, ifid_instr[21:0]};

    wire [31:0] id_imm;
    assign id_imm = (id_opcode == `OP_SVPC) ? imm22 : imm10; // If SVPC then use imm22

    // Control Signals

    wire c_reg_write;
    wire c_mem_read;
    wire c_mem_write;
    wire c_mem_to_reg;
    wire c_alu_src;

    wire c_svpc;
    wire c_jm;
    wire c_brz;
    wire c_brn;

    wire [2:0] c_alu_ctl;

    control_unit CU(
        .opcode(id_opcode),

        .reg_write(c_reg_write),
        .mem_read(c_mem_read),
        .mem_write(c_mem_write),
        .mem_to_reg(c_mem_to_reg),
        .alu_src(c_alu_src),

        .svpc(c_svpc),
        .jm(c_jm),
        .brz(c_brz),
        .brn(c_brn),

        .alu_ctl(c_alu_ctl)
    );

    // ============================================================
    // WB STAGE SIGNALS
    // ============================================================

    wire memwb_reg_write;
    wire memwb_mem_to_reg;
    wire [5:0] memwb_rd;
    wire [31:0] memwb_alu_result;
    wire [31:0] memwb_mem_data;

    wire [31:0] wb_write_data;

    mux2_32 WB_MUX(
        .in0(memwb_alu_result),
        .in1(memwb_mem_data),
        .sel(memwb_mem_to_reg),
        .out(wb_write_data)
    );

    // ============================================================
    // REGISTER FILE
    // ============================================================

    wire [31:0] rf_rd1;
    wire [31:0] rf_rd2;

    register_file RF(
        .clk(clk),
        .reset(reset),

        .rs(id_rs),
        .rt(id_rt),

        .write_reg(memwb_rd),
        .write_data(wb_write_data),
        .reg_write(memwb_reg_write),

        .read_data1(rf_rd1),
        .read_data2(rf_rd2)
    );

    // ============================================================
    // ID/EX REGISTER
    // ============================================================

    wire idex_reg_write;
    wire idex_mem_read;
    wire idex_mem_write;
    wire idex_mem_to_reg;
    wire idex_alu_src;

    wire idex_svpc;
    wire idex_jm;
    wire idex_brz;
    wire idex_brn;

    wire [2:0] idex_alu_ctl;

    wire [31:0] idex_pc;
    wire [31:0] idex_rd1;
    wire [31:0] idex_rd2;
    wire [31:0] idex_imm;

    wire [5:0] idex_rd;
    wire [5:0] idex_rs;
    wire [5:0] idex_rt;

    wire flush_idex;

    id_ex_reg ID_EX(
        .clk(clk),
        .reset(reset),
        .stall(stall_pipeline),
        .flush(flush_idex),

        .reg_write_in(c_reg_write),
        .mem_read_in(c_mem_read),
        .mem_write_in(c_mem_write),
        .mem_to_reg_in(c_mem_to_reg),
        .alu_src_in(c_alu_src),

        .svpc_in(c_svpc),
        .jm_in(c_jm),
        .brz_in(c_brz),
        .brn_in(c_brn),

        .alu_ctl_in(c_alu_ctl),

        .pc_in(ifid_pc),
        .rd1_in(rf_rd1),
        .rd2_in(rf_rd2),
        .imm_in(id_imm),

        .rd_in(id_rd),
        .rs_in(id_rs),
        .rt_in(id_rt),

        .reg_write_out(idex_reg_write),
        .mem_read_out(idex_mem_read),
        .mem_write_out(idex_mem_write),
        .mem_to_reg_out(idex_mem_to_reg),
        .alu_src_out(idex_alu_src),

        .svpc_out(idex_svpc),
        .jm_out(idex_jm),
        .brz_out(idex_brz),
        .brn_out(idex_brn),

        .alu_ctl_out(idex_alu_ctl),

        .pc_out(idex_pc),
        .rd1_out(idex_rd1),
        .rd2_out(idex_rd2),
        .imm_out(idex_imm),

        .rd_out(idex_rd),
        .rs_out(idex_rs),
        .rt_out(idex_rt)
    );

    // ============================================================
    // EX STAGE
    // ============================================================

    wire exmem_reg_write;
    wire exmem_mem_read;
    wire exmem_mem_write;
    wire exmem_mem_to_reg;

    wire exmem_jm;

    wire [31:0] exmem_alu_result;
    wire [31:0] exmem_write_data;
    wire [5:0] exmem_rd;

    wire exmem_z;
    wire exmem_n;
    wire exmem_updates_flags;

    wire [1:0] forward_a;
    wire [1:0] forward_b;

    forwarding_unit FU(
        .idex_rs(idex_rs),
        .idex_rt(idex_rt),

        .exmem_rd(exmem_rd),
        .exmem_reg_write(exmem_reg_write),
        .exmem_mem_to_reg(exmem_mem_to_reg),

        .memwb_rd(memwb_rd),
        .memwb_reg_write(memwb_reg_write),

        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    wire [31:0] alu_a_forwarded;
    wire [31:0] alu_b_forwarded;

    mux3_32 FORWARD_A_MUX(
        .in0(idex_rd1),
        .in1(wb_write_data),
        .in2(exmem_alu_result),
        .sel(forward_a),
        .out(alu_a_forwarded)
    );

    mux3_32 FORWARD_B_MUX(
        .in0(idex_rd2),
        .in1(wb_write_data),
        .in2(exmem_alu_result),
        .sel(forward_b),
        .out(alu_b_forwarded)
    );

    wire [31:0] alu_a;
    wire [31:0] alu_b;

    mux2_32 SVPC_MUX(
        .in0(alu_a_forwarded),
        .in1(idex_pc),
        .sel(idex_svpc),
        .out(alu_a)
    );

    mux2_32 ALUSRC_MUX(
        .in0(alu_b_forwarded),
        .in1(idex_imm),
        .sel(idex_alu_src),
        .out(alu_b)
    );

    wire [31:0] alu_out;
    wire alu_z;
    wire alu_n;

    scu_alu ALU(
        .A(alu_a),
        .B(alu_b),
        .alu_ctl(idex_alu_ctl),
        .OUT(alu_out),
        .Z(alu_z),
        .N(alu_n)
    );

    // ============================================================
    // PREVIOUS FLAGS FOR BRZ / BRN
    // ============================================================

    reg prev_z; // Stores whether the previous ALU result was 0
    reg prev_n; // Stores whether the previous ALU result was negative

    wire branch_flag_z;
    wire branch_flag_n;

    assign branch_flag_z = exmem_updates_flags ? exmem_z : prev_z; // If instruction in EX/MEM --> update flags and use its zero flag; else, use the older stored previous zero flag
    assign branch_flag_n = exmem_updates_flags ? exmem_n : prev_n; // If instruction in EX/MEM --> update flags and use its neg flag; else, use the older stored previous neg flag

    wire branch_taken_ex;

    assign branch_taken_ex =
        (idex_brz && branch_flag_z) ||
        (idex_brn && branch_flag_n);

    wire [31:0] branch_target_ex;
    assign branch_target_ex = alu_a_forwarded;

    wire updates_flags_ex;

    // Should we update the current flags or not --> if it is BRZ, BRN, or JM then don't because we don't want to overwrite the previous ALU flags
    // Only update flags for real working instruction
    assign updates_flags_ex =
        !(idex_brz || idex_brn || idex_jm) &&
        (idex_reg_write || idex_mem_write || idex_mem_read);

    // IMPORTANT:
    // Do not flush EX/MEM on branch.
    // Only younger instructions in IF/ID and ID/EX should be flushed.
    wire flush_exmem;
    assign flush_exmem = 1'b0;

    ex_mem_reg EX_MEM(
        .clk(clk),
        .reset(reset),
        .stall(stall_pipeline),
        .flush(flush_exmem),

        .reg_write_in(idex_reg_write),
        .mem_read_in(idex_mem_read),
        .mem_write_in(idex_mem_write),
        .mem_to_reg_in(idex_mem_to_reg),

        .jm_in(idex_jm),

        .alu_result_in(alu_out),
        .write_data_in(alu_b_forwarded),

        .rd_in(idex_rd),

        .z_in(alu_z),
        .n_in(alu_n),
        .updates_flags_in(updates_flags_ex),

        .reg_write_out(exmem_reg_write),
        .mem_read_out(exmem_mem_read),
        .mem_write_out(exmem_mem_write),
        .mem_to_reg_out(exmem_mem_to_reg),

        .jm_out(exmem_jm),

        .alu_result_out(exmem_alu_result),
        .write_data_out(exmem_write_data),

        .rd_out(exmem_rd),

        .z_out(exmem_z),
        .n_out(exmem_n),
        .updates_flags_out(exmem_updates_flags)
    );

    // ============================================================
    // MEM STAGE
    // ============================================================

    wire [31:0] dmem_read_data;

    data_memory DM(
        .clk(clk),
        .reset(reset),

        .mem_read(exmem_mem_read),
        .mem_write(exmem_mem_write),

        .addr(exmem_alu_result),
        .write_data(exmem_write_data),

        .read_data(dmem_read_data)
    );

    // ============================================================
    // PC REDIRECT LOGIC
    // ============================================================

    wire [31:0] pc_redirect_mux_out;

    mux2_32 PC_REDIRECT_MUX(
        .in0(dmem_read_data),
        .in1(branch_target_ex),
        .sel(branch_taken_ex),
        .out(pc_redirect_mux_out)
    );

    assign pc_redirect = pc_redirect_mux_out;

    assign pc_redirect_valid = branch_taken_ex || exmem_jm;

    // Flush younger instructions after branch or jump redirect.
    assign flush_ifid = pc_redirect_valid;
    assign flush_idex = pc_redirect_valid;

    // ============================================================
    // MEM/WB REGISTER
    // ============================================================

    mem_wb_reg MEM_WB(
        .clk(clk),
        .reset(reset),
        .stall(stall_pipeline),

        .reg_write_in(exmem_reg_write),
        .mem_to_reg_in(exmem_mem_to_reg),

        .rd_in(exmem_rd),
        .alu_result_in(exmem_alu_result),
        .mem_data_in(dmem_read_data),

        .reg_write_out(memwb_reg_write),
        .mem_to_reg_out(memwb_mem_to_reg),

        .rd_out(memwb_rd),
        .alu_result_out(memwb_alu_result),
        .mem_data_out(memwb_mem_data)
    );

    // ============================================================
    // UPDATE PREVIOUS FLAGS
    // ============================================================

    always @(negedge clk or posedge reset) begin
        if (reset) begin
            prev_z <= 1'b0;
            prev_n <= 1'b0;
        end else begin
            if (exmem_updates_flags) begin
                prev_z <= exmem_z;
                prev_n <= exmem_n;
            end
        end
    end

endmodule