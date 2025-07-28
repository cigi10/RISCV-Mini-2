`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2025 12:22:54
// Design Name: 
// Module Name: riscv_if_stage
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


module riscv_if_stage (
    input  logic clk,
    input  logic rst_n,
    input  logic stall,
    input  logic branch_taken,
    input  logic [31:0] branch_target,
    output logic [31:0] pc,
    output logic [31:0] pc_next,
    output logic [31:0] instruction
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= '0;
        end
        else if (!stall) begin
            if (branch_taken) begin
                pc <= branch_target;
            end
            else begin
                pc <= pc + 4;
            end
        end
    end

    assign pc_next = branch_taken ? branch_target : (pc + 4);

    instruction_memory imem (
        .clk(clk),
        .addr(pc[11:2]),
        .instruction(instruction)
    );

endmodule

module instruction_memory (
    input  logic        clk,
    input  logic [9:0]  addr,
    output logic [31:0] instruction
);

    logic [31:0] memory [0:1023];
    
    initial begin
        integer i;
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 32'h00000013;
        end
        
      memory[0] = 32'h00310093;   // ADDI - x1, x2, 3
      memory[1] = 32'h00408113;   // ADDI - x2, x1, 4
      memory[2] = 32'h002081B3;   // ADD  - x3, x1, x2
      memory[3] = 32'h40208233;   // SUB  - x4, x1, x2
      memory[4] = 32'h0020F2B3;   // AND  - x5, x1, x2
      memory[5] = 32'h0020E333;   // OR   - x6, x1, x2
      memory[6] = 32'h0020C3B3;   // XOR  - x7, x1, x2
      memory[7] = 32'h00000013;   // NOP
      memory[8] = 32'h00000013;   // NOP
      memory[9] = 32'h00000013;   // NOP
    end
    
    always_ff @(posedge clk) begin
        instruction <= memory[addr];
    end

endmodule

