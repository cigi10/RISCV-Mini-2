`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2025 13:36:52
// Design Name: 
// Module Name: riscv_if_stage_tb
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


module riscv_if_stage_tb;

    // testbench signals
    reg clk;
    reg rst_n;
    reg stall;
    reg branch_taken;
    reg  [31:0] branch_target;
    wire [31:0] instruction;
    wire [31:0] pc;
    wire [31:0] pc_next;
    
    // clock generation - fixes ASSIGN-5 warning
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz clock (20ns period)
    end
    
    // reset and stimulus generation
    initial begin
        // initialize inputs
        rst_n = 0;
        stall = 0;
        branch_taken = 0;
        branch_target = 32'h0;
        
        // apply reset
        #25;
        rst_n = 1;
        
        // normal operation test
        #100;
        
        // test stall condition
        stall = 1;
        #40;
        stall = 0;
        
        // test branch
        #40;
        branch_taken = 1;
        branch_target = 32'h100;
        #20;
        branch_taken = 0;
        
        // continue normal operation
        #200;
        
        $display("Testbench completed successfully");
        $finish;
    end
    
    // monitor outputs
    initial begin
        $monitor("Time: %0t | PC: %h | PC_Next: %h | Instruction: %h | Stall: %b", 
                 $time, pc, pc_next, instruction, stall);
    end
    
    // assertions for verification
    always @(posedge clk) begin
        if (rst_n) begin
            // check PC increment when not stalled or branching
            if (!stall && !branch_taken) begin
                if (pc_next !== pc + 4) begin
                    $error("PC increment error at time %0t: expected %h, got %h", 
                           $time, pc + 4, pc_next);
                end
            end
            
            // check branch behavior
            if (branch_taken) begin
                if (pc_next !== branch_target) begin
                    $error("Branch error at time %0t: expected %h, got %h", 
                           $time, branch_target, pc_next);
                end
            end
        end
    end
    
    riscv_if_stage dut (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .instruction(instruction),
        .pc(pc),
        .pc_next(pc_next)
    );

endmodule
