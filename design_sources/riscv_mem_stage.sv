`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2025 12:24:43
// Design Name: 
// Module Name: riscv_mem_stage
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


module riscv_mem_stage (
    input  logic clk,
    input  logic rst_n,
    input  logic [31:0] alu_result,
    input  logic [31:0] write_data,
    input  logic mem_read,
    input  logic mem_write,
    output logic [31:0] read_data
);

    // Suppress unused ALU result bits (only using [11:2] for word addressing)
    (* DONT_TOUCH = "TRUE" *) wire _alu_unused = |{alu_result[31:12], alu_result[1:0]};

    data_memory dmem (
        .clk(clk),
        .rst_n(rst_n),
        .addr(alu_result[11:2]), // Word-aligned addressing (10 bits)
        .write_data(write_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .read_data(read_data)
    );

endmodule

module data_memory (
    input  logic clk,
    input  logic rst_n,
    input  logic [9:0]  addr,
    input  logic [31:0] write_data,
    input  logic mem_read,
    input  logic mem_write,
    output logic [31:0] read_data
);

    logic [31:0] memory [0:1023];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 1024; i++) begin
                memory[i] <= '0;
            end
        end
        else if (mem_write) begin
            memory[addr] <= write_data;
        end
    end

    always_comb begin
        if (mem_read) begin
            read_data = memory[addr];
        end
        else begin
            read_data = '0;
        end
    end

endmodule
