`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2025 12:24:43
// Design Name: 
// Module Name: riscv_ex_stage
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


module riscv_ex_stage (
    input  logic [31:0] pc,
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] immediate,
    input  logic [3:0]  alu_op,
    input  logic alu_src,
    input  logic branch,
    input  logic jump,
    output logic [31:0] alu_result,
    output logic [31:0] branch_target,
    output logic branch_taken
);

    logic [31:0] alu_input2;
    logic zero_flag;

    assign alu_input2 = alu_src ? immediate : rs2_data;
    assign branch_target = pc + immediate;

    alu main_alu (
        .input1(rs1_data),
        .input2(alu_input2),
        .alu_op(alu_op),
        .result(alu_result),
        .zero(zero_flag)
    );

    always_comb begin
        if (jump) begin
            branch_taken = 1'b1;
        end
        else if (branch) begin
            case (alu_op)
                4'b0001: branch_taken = zero_flag; // BEQ
                default: branch_taken = 1'b0;
            endcase
        end
        else begin
            branch_taken = 1'b0;
        end
    end

endmodule

module alu (
    input  logic [31:0] input1,
    input  logic [31:0] input2,
    input  logic [3:0]  alu_op,
    output logic [31:0] result,
    output logic zero
);

    always_comb begin
        case (alu_op)
            4'b0000: result = input1 + input2; // ADD
            4'b0001: result = input1 - input2; // SUB
            4'b0010: result = input1 & input2; // AND
            4'b0011: result = input1 | input2; // OR
            4'b0100: result = input1 ^ input2; // XOR
            default: result = '0;
        endcase
    end

    assign zero = (result == '0);

endmodule
