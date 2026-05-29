`timescale 1ns/1ps

module forwarding_unit(
    input [5:0] idex_rs,
    input [5:0] idex_rt,

    input [5:0] exmem_rd,
    input exmem_reg_write,
    input exmem_mem_to_reg,

    input [5:0] memwb_rd,
    input memwb_reg_write,

    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);
    always @(*) begin
        forward_a = 2'b00;
        forward_b = 2'b00;

        // 00 = use original ID/EX value
        // 01 = forward from MEM/WB
        // 10 = forward from EX/MEM

        if (exmem_reg_write && !exmem_mem_to_reg && (exmem_rd == idex_rs))
            forward_a = 2'b10;
        else if (memwb_reg_write && (memwb_rd == idex_rs))
            forward_a = 2'b01;

        if (exmem_reg_write && !exmem_mem_to_reg && (exmem_rd == idex_rt))
            forward_b = 2'b10;
        else if (memwb_reg_write && (memwb_rd == idex_rt))
            forward_b = 2'b01;
    end
endmodule