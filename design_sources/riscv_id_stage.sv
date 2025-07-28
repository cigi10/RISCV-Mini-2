`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2025 12:24:43
// Design Name: 
// Module Name: riscv_id_stage
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


module riscv_id_stage (
    input  logic clk,
    input  logic rst_n,
    input  logic [31:0] instruction,
    input  logic [31:0] pc,          // unused for now
    input  logic wb_reg_write,
    input  logic [4:0]  wb_rd,
    input  logic [31:0] wb_data,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] immediate,
    output logic [3:0]  alu_op,
    output logic reg_write,
    output logic mem_read,
    output logic mem_write,
    output logic branch,
    output logic jump,
    output logic alu_src,
    output logic [1:0]  wb_src
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    // suppress unused PC warning (reserved for future branch prediction)
    (* DONT_TOUCH = "TRUE" *) wire _pc_unused = |pc;

    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd = instruction[11:7];

    register_file rf (
        .clk(clk),
        .rst_n(rst_n),
        .read_addr1(rs1),
        .read_addr2(rs2),
        .write_addr(wb_rd),
        .write_data(wb_data),
        .write_enable(wb_reg_write),
        .read_data1(rs1_data),
        .read_data2(rs2_data)
    );

    immediate_generator imm_gen (
        .instruction(instruction),
        .immediate(immediate)
    );

    control_unit ctrl (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .jump(jump),
        .alu_src(alu_src),
        .wb_src(wb_src)
    );

endmodule

module register_file (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [4:0]  read_addr1,
    input  logic [4:0]  read_addr2,
    input  logic [4:0]  write_addr,
    input  logic [31:0] write_data,
    input  logic        write_enable,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);

    logic [31:0] registers [0:31];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                registers[i] <= '0;
            end
        end
        else if (write_enable && write_addr != 5'b0) begin
            registers[write_addr] <= write_data;
        end
    end

    assign read_data1 = (read_addr1 == 5'b0) ? '0 : registers[read_addr1];
    assign read_data2 = (read_addr2 == 5'b0) ? '0 : registers[read_addr2];

endmodule

module immediate_generator (
    input  logic [31:0] instruction,
    output logic [31:0] immediate
);

    logic [6:0] opcode;
    assign opcode = instruction[6:0];

    always_comb begin
        case (opcode)
            7'b0010011: begin 
            // I-type (ADDI, etc.)
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end
            7'b0100011: begin 
            // S-type (SW)
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            7'b0000011: begin 
            // I-type (LW)
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end
            7'b1100011: begin
            // B-type (BEQ, BNE)
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], 
                           instruction[30:25], instruction[11:8], 1'b0};
            end
            7'b1101111: begin
            // J-type (JAL)
                immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12],
                           instruction[20], instruction[30:21], 1'b0};
            end
            7'b0110111: begin 
            // U-type (LUI)
                immediate = {instruction[31:12], 12'b0};
            end
            default: begin
                immediate = '0;
            end
        endcase
    end

endmodule

module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [3:0] alu_op,
    output logic reg_write,
    output logic mem_read,
    output logic mem_write,
    output logic branch,
    output logic jump,
    output logic alu_src,
    output logic [1:0] wb_src
);

    always_comb begin
        reg_write = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        branch = 1'b0;
        jump = 1'b0;
        alu_src = 1'b0;
        wb_src = 2'b00;
        alu_op = 4'b0000;

        case (opcode)
            7'b0110011: begin 
            // R-type (ADD, SUB, AND, OR, XOR)
                reg_write = 1'b1;
                alu_src = 1'b0;
                wb_src = 2'b00;
                case ({funct7, funct3})
                    10'b0000000000: alu_op = 4'b0000; // ADD
                    10'b0100000000: alu_op = 4'b0001; // SUB
                    10'b0000000111: alu_op = 4'b0010; // AND
                    10'b0000000110: alu_op = 4'b0011; // OR
                    10'b0000000100: alu_op = 4'b0100; // XOR
                    default: alu_op = 4'b0000;
                endcase
            end
            7'b0010011: begin 
            // I-type (ADDI)
                reg_write = 1'b1;
                alu_src = 1'b1;
                wb_src = 2'b00;
                case (funct3)
                    3'b000: alu_op = 4'b0000; // ADDI
                    3'b111: alu_op = 4'b0010; // ANDI
                    3'b110: alu_op = 4'b0011; // ORI
                    3'b100: alu_op = 4'b0100; // XORI
                    default: alu_op = 4'b0000;
                endcase
            end
            7'b0000011: begin // Load (LW)
                reg_write = 1'b1;
                mem_read = 1'b1;
                alu_src = 1'b1;
                wb_src = 2'b01;
                alu_op = 4'b0000; // ADD for address calculation
            end
            7'b0100011: begin 
            // Store (SW)
                mem_write = 1'b1;
                alu_src = 1'b1;
                alu_op = 4'b0000; // ADD for address calculation
            end
            7'b1100011: begin 
            // Branch (BEQ, BNE)
                branch = 1'b1;
                alu_src = 1'b0;
                case (funct3)
                    3'b000: alu_op = 4'b0001; // BEQ (SUB for comparison)
                    3'b001: alu_op = 4'b0001; // BNE (SUB for comparison)
                    default: alu_op = 4'b0001;
                endcase
            end
            7'b1101111: begin // JAL
                reg_write = 1'b1;
                jump = 1'b1;
                wb_src = 2'b10; // PC + 4
            end
            default: begin
                // NOP or unsupported instruction
            end
        endcase
    end

endmodule
