`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2025 12:24:43
// Design Name: 
// Module Name: riscv_hazard_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module riscv_hazard_unit (
    input  logic [4:0] id_rs1,
    input  logic [4:0] id_rs2,
    input  logic [4:0] ex_rd,
    input  logic ex_mem_read,
    input  logic [4:0] mem_rd,
    input  logic mem_reg_write,
    input  logic [4:0] wb_rd,
    input  logic wb_reg_write,
    output logic [1:0] forward_rs1,
    output logic [1:0] forward_rs2,
    output logic load_use_hazard
);

    always_comb begin
        forward_rs1 = 2'b00;
        forward_rs2 = 2'b00;

        // EX hazard forwarding
        if (mem_reg_write && (mem_rd != 5'b0) && (mem_rd == id_rs1)) begin
            forward_rs1 = 2'b10;
        end
        else if (wb_reg_write && (wb_rd != 5'b0) && (wb_rd == id_rs1)) begin
            forward_rs1 = 2'b01;
        end

        if (mem_reg_write && (mem_rd != 5'b0) && (mem_rd == id_rs2)) begin
            forward_rs2 = 2'b10;
        end
        else if (wb_reg_write && (wb_rd != 5'b0) && (wb_rd == id_rs2)) begin
            forward_rs2 = 2'b01;
        end

        // load-use hazard detection
        load_use_hazard = ex_mem_read && (ex_rd != 5'b0) && 
           ((ex_rd == id_rs1) || (ex_rd == id_rs2));
    end

endmodule

module riscv_forward_unit (
    input  logic [31:0] id_ex_rs1_data,
    input  logic [31:0] id_ex_rs2_data,
    input  logic [31:0] ex_mem_alu_result,
    input  logic [31:0] mem_wb_write_data,
    input  logic [1:0]  forward_rs1,
    input  logic [1:0]  forward_rs2,
    output logic [31:0] forwarded_rs1_data,
    output logic [31:0] forwarded_rs2_data
);

    always_comb begin
        case (forward_rs1)
            2'b00: forwarded_rs1_data = id_ex_rs1_data;
            2'b01: forwarded_rs1_data = mem_wb_write_data;
            2'b10: forwarded_rs1_data = ex_mem_alu_result;
            default: forwarded_rs1_data = id_ex_rs1_data;
        endcase

        case (forward_rs2)
            2'b00: forwarded_rs2_data = id_ex_rs2_data;
            2'b01: forwarded_rs2_data = mem_wb_write_data;
            2'b10: forwarded_rs2_data = ex_mem_alu_result;
            default: forwarded_rs2_data = id_ex_rs2_data;
        endcase
    end

endmodule
