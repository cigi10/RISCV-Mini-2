`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2025 12:34:24
// Design Name: 
// Module Name: riscv_pipeline_top_tb
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


module riscv_pipeline_top_tb;
    logic clk;
    logic rst_n;
    logic [31:0] debug_pc;
    logic [31:0] debug_instr;
    logic [31:0] debug_reg_data;
    logic [4:0]  debug_reg_addr;
    logic debug_reg_we;

    riscv_pipeline_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .debug_pc(debug_pc),
        .debug_instr(debug_instr),
        .debug_reg_data(debug_reg_data),
        .debug_reg_addr(debug_reg_addr),
        .debug_reg_we(debug_reg_we)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #15 rst_n = 1;
        
        #500;
        
        $display("=== simulation complete ===");
        $display("final PC: %h", debug_pc);
        $finish;
    end

    // monitor pipeline operation
    always @(posedge clk) begin
        if (rst_n) begin
            $display("cycle %0t: PC=%h, Instr=%h", $time, debug_pc, debug_instr);
            if (debug_reg_we) begin
                $display("  -> register x%0d = %h", debug_reg_addr, debug_reg_data);
            end
        end
    end

    // dump waveforms
    initial begin
        $dumpfile("riscv_pipeline.vcd");
        $dumpvars(0, riscv_pipeline_top_tb);
    end

endmodule
