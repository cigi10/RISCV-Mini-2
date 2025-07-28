`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2025 12:22:54
// Design Name: 
// Module Name: riscv_pipeline_top
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


module riscv_pipeline_top (
    input  logic clk,
    input  logic rst_n,
    output logic [31:0] debug_pc,
    output logic [31:0] debug_instr,
    output logic [31:0] debug_reg_data,
    output logic [4:0]  debug_reg_addr,
    output logic debug_reg_we
);

    // pipeline registers
    logic [31:0] if_id_pc, if_id_pc_plus4, if_id_instr;
    logic if_id_valid;
    
    logic [31:0] id_ex_pc, id_ex_pc_plus4, id_ex_instr;
    logic [31:0] id_ex_rs1_data, id_ex_rs2_data, id_ex_imm;
    logic [4:0]  id_ex_rs1, id_ex_rs2, id_ex_rd;
    logic [3:0]  id_ex_alu_op;
    logic id_ex_reg_write, id_ex_mem_read, id_ex_mem_write;
    logic id_ex_branch, id_ex_jump, id_ex_alu_src;
    logic [1:0]  id_ex_wb_src;
    logic id_ex_valid;
    
    logic [31:0] ex_mem_pc_plus4, ex_mem_alu_result, ex_mem_rs2_data;
    logic [4:0]  ex_mem_rd;
    logic ex_mem_reg_write, ex_mem_mem_read, ex_mem_mem_write;
    logic [1:0]  ex_mem_wb_src;
    logic ex_mem_branch_taken;
    logic [31:0] ex_mem_branch_target;
    logic ex_mem_valid;
    
    logic [31:0] mem_wb_pc_plus4, mem_wb_alu_result, mem_wb_mem_data;
    logic [4:0]  mem_wb_rd;
    logic mem_wb_reg_write;
    logic [1:0]  mem_wb_wb_src;
    logic mem_wb_valid;

    // stage interconnects
    logic [31:0] if_pc, if_pc_next, if_instruction;
    logic if_stall;
    
    logic [31:0] id_rs1_data, id_rs2_data, id_immediate;
    logic [4:0]  id_rs1, id_rs2, id_rd;
    logic [3:0]  id_alu_op;
    logic id_reg_write, id_mem_read, id_mem_write;
    logic id_branch, id_jump, id_alu_src;
    logic [1:0]  id_wb_src;
    logic id_stall, id_flush;
    
    logic [31:0] ex_alu_result, ex_branch_target;
    logic ex_branch_taken;
    logic [31:0] ex_forward_rs1, ex_forward_rs2;
    
    logic [31:0] mem_read_data;
    logic [31:0] wb_write_data;

    // hazard control
    logic [1:0] forward_rs1, forward_rs2;
    logic load_use_hazard;

    // suppress linter warnings for signals during development
    assign id_stall = 1'b0;  // for load-use hazard handling
    
    // Suppress unused signal warnings (these signals are kept for debug/development)
    (* DONT_TOUCH = "TRUE" *) wire _unused_ok = &{1'b0, 
        id_ex_instr[31:0],     // keep instruction for debug
        id_ex_rs1[4:0],        // keep register addresses for hazard detection
        id_ex_rs2[4:0],        // keep register addresses for hazard detection  
        if_pc_next[31:0],      // keep for branch target calculation
        id_stall               // keep for stall logic
    };

    // pipeline stages
    riscv_if_stage if_stage (
        .clk(clk),
        .rst_n(rst_n),
        .stall(if_stall),
        .branch_taken(ex_mem_branch_taken),
        .branch_target(ex_mem_branch_target),
        .pc(if_pc),
        .pc_next(if_pc_next),
        .instruction(if_instruction)
    );

    riscv_id_stage id_stage (
        .clk(clk),
        .rst_n(rst_n),
        .instruction(if_id_instr),
        .pc(if_id_pc),
        .wb_reg_write(mem_wb_reg_write),
        .wb_rd(mem_wb_rd),
        .wb_data(wb_write_data),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .rd(id_rd),
        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data),
        .immediate(id_immediate),
        .alu_op(id_alu_op),
        .reg_write(id_reg_write),
        .mem_read(id_mem_read),
        .mem_write(id_mem_write),
        .branch(id_branch),
        .jump(id_jump),
        .alu_src(id_alu_src),
        .wb_src(id_wb_src)
    );

    riscv_ex_stage ex_stage (
        .pc(id_ex_pc),
        .rs1_data(ex_forward_rs1),
        .rs2_data(ex_forward_rs2),
        .immediate(id_ex_imm),
        .alu_op(id_ex_alu_op),
        .alu_src(id_ex_alu_src),
        .branch(id_ex_branch),
        .jump(id_ex_jump),
        .alu_result(ex_alu_result),
        .branch_target(ex_branch_target),
        .branch_taken(ex_branch_taken)
    );

    riscv_mem_stage mem_stage (
        .clk(clk),
        .rst_n(rst_n),
        .alu_result(ex_mem_alu_result),
        .write_data(ex_mem_rs2_data),
        .mem_read(ex_mem_mem_read),
        .mem_write(ex_mem_mem_write),
        .read_data(mem_read_data)
    );

    riscv_wb_stage wb_stage (
        .pc_plus4(mem_wb_pc_plus4),
        .alu_result(mem_wb_alu_result),
        .mem_data(mem_wb_mem_data),
        .wb_src(mem_wb_wb_src),
        .write_data(wb_write_data)
    );

    // Hazard unit connections - matches port names in riscv_hazard_unit.sv
    riscv_hazard_unit hazard_unit (
        .id_rs1(id_rs1),                 // From ID stage output
        .id_rs2(id_rs2),                 // From ID stage output
        .ex_rd(id_ex_rd),                // From ID/EX pipeline register
        .ex_mem_read(id_ex_mem_read),    // From ID/EX pipeline register
        .mem_rd(ex_mem_rd),              // From EX/MEM pipeline register
        .mem_reg_write(ex_mem_reg_write), // From EX/MEM pipeline register
        .wb_rd(mem_wb_rd),               // From MEM/WB pipeline register
        .wb_reg_write(mem_wb_reg_write), // From MEM/WB pipeline register
        .forward_rs1(forward_rs1),       // Output to forwarding unit
        .forward_rs2(forward_rs2),       // Output to forwarding unit
        .load_use_hazard(load_use_hazard) // Output for stall control
    );

    riscv_forward_unit forward_unit (
        .id_ex_rs1_data(id_ex_rs1_data),
        .id_ex_rs2_data(id_ex_rs2_data),
        .ex_mem_alu_result(ex_mem_alu_result),
        .mem_wb_write_data(wb_write_data),
        .forward_rs1(forward_rs1),
        .forward_rs2(forward_rs2),
        .forwarded_rs1_data(ex_forward_rs1),
        .forwarded_rs2_data(ex_forward_rs2)
    );

    // pipeline control
    assign if_stall = load_use_hazard;
    assign id_flush = ex_mem_branch_taken;

    // IF/ID pipeline register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            if_id_pc <= 32'h0;
            if_id_pc_plus4 <= 32'h4;
            if_id_instr <= 32'h0;
            if_id_valid <= 1'b0;
        end
        else if (!if_stall) begin
            if_id_pc <= if_pc;
            if_id_pc_plus4 <= if_pc + 32'd4;
            if_id_instr <= if_instruction;
            if_id_valid <= 1'b1;
        end
    end

    // ID/EX pipeline register
    always_ff @(posedge clk) begin
        if (!rst_n || id_flush) begin
            id_ex_pc <= 32'h0;
            id_ex_pc_plus4 <= 32'h0;
            id_ex_instr <= 32'h0;
            id_ex_rs1_data <= 32'h0;
            id_ex_rs2_data <= 32'h0;
            id_ex_imm <= 32'h0;
            id_ex_rs1 <= 5'h0;
            id_ex_rs2 <= 5'h0;
            id_ex_rd <= 5'h0;
            id_ex_alu_op <= 4'h0;
            id_ex_reg_write <= 1'b0;
            id_ex_mem_read <= 1'b0;
            id_ex_mem_write <= 1'b0;
            id_ex_branch <= 1'b0;
            id_ex_jump <= 1'b0;
            id_ex_alu_src <= 1'b0;
            id_ex_wb_src <= 2'h0;
            id_ex_valid <= 1'b0;
        end
        else begin
            id_ex_pc <= if_id_pc;
            id_ex_pc_plus4 <= if_id_pc_plus4;
            id_ex_instr <= if_id_instr;
            id_ex_rs1_data <= id_rs1_data;
            id_ex_rs2_data <= id_rs2_data;
            id_ex_imm <= id_immediate;
            id_ex_rs1 <= id_rs1;
            id_ex_rs2 <= id_rs2;
            id_ex_rd <= id_rd;
            id_ex_alu_op <= id_alu_op;
            id_ex_reg_write <= id_reg_write;
            id_ex_mem_read <= id_mem_read;
            id_ex_mem_write <= id_mem_write;
            id_ex_branch <= id_branch;
            id_ex_jump <= id_jump;
            id_ex_alu_src <= id_alu_src;
            id_ex_wb_src <= id_wb_src;
            id_ex_valid <= if_id_valid;
        end
    end

    // EX/MEM pipeline register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_mem_pc_plus4 <= 32'h0;
            ex_mem_alu_result <= 32'h0;
            ex_mem_rs2_data <= 32'h0;
            ex_mem_rd <= 5'h0;
            ex_mem_reg_write <= 1'b0;
            ex_mem_mem_read <= 1'b0;
            ex_mem_mem_write <= 1'b0;
            ex_mem_wb_src <= 2'h0;
            ex_mem_branch_taken <= 1'b0;
            ex_mem_branch_target <= 32'h0;
            ex_mem_valid <= 1'b0;
        end
        else begin
            ex_mem_pc_plus4 <= id_ex_pc_plus4;
            ex_mem_alu_result <= ex_alu_result;
            ex_mem_rs2_data <= ex_forward_rs2;
            ex_mem_rd <= id_ex_rd;
            ex_mem_reg_write <= id_ex_reg_write;
            ex_mem_mem_read <= id_ex_mem_read;
            ex_mem_mem_write <= id_ex_mem_write;
            ex_mem_wb_src <= id_ex_wb_src;
            ex_mem_branch_taken <= ex_branch_taken;
            ex_mem_branch_target <= ex_branch_target;
            ex_mem_valid <= id_ex_valid;
        end
    end

    // MEM/WB pipeline register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_wb_pc_plus4 <= 32'h0;
            mem_wb_alu_result <= 32'h0;
            mem_wb_mem_data <= 32'h0;
            mem_wb_rd <= 5'h0;
            mem_wb_reg_write <= 1'b0;
            mem_wb_wb_src <= 2'h0;
            mem_wb_valid <= 1'b0;
        end
        else begin
            mem_wb_pc_plus4 <= ex_mem_pc_plus4;
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_mem_data <= mem_read_data;
            mem_wb_rd <= ex_mem_rd;
            mem_wb_reg_write <= ex_mem_reg_write;
            mem_wb_wb_src <= ex_mem_wb_src;
            mem_wb_valid <= ex_mem_valid;
        end
    end

    // Debug outputs
    assign debug_pc = if_pc;
    assign debug_instr = if_instruction;
    assign debug_reg_data = wb_write_data;
    assign debug_reg_addr = mem_wb_rd;
    assign debug_reg_we = mem_wb_reg_write && mem_wb_valid;

endmodule
