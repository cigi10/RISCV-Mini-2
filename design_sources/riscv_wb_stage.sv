`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2025 12:24:43
// Design Name: 
// Module Name: riscv_wb_stage
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


module riscv_wb_stage (
    input  logic [31:0] pc_plus4,
    input  logic [31:0] alu_result,
    input  logic [31:0] mem_data,
    input  logic [1:0]  wb_src,
    output logic [31:0] write_data
);

    always_comb begin
        case (wb_src)
            2'b00: write_data = alu_result; // ALU result
            2'b01: write_data = mem_data; // memory data
            2'b10: write_data = pc_plus4; // PC + 4 (for JAL)
            default: write_data = alu_result;
        endcase
    end

endmodule
