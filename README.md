# RISCV-Mini-2

A complete 32-bit RISC-V processor implementation in SystemVerilog, designed for the Basys 3 FPGA development board (Artix-7). This project demonstrates a fully functional pipelined CPU with hazard detection, data forwarding, and comprehensive debug capabilities.

## Features

- **5-Stage Pipeline**: Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory (MEM), Write-Back (WB)
- **Harvard Architecture**: Separate 4KB instruction and data memories using block RAM
- **Hazard Handling**: Data forwarding unit and load-use hazard detection with pipeline stalling
- **Debug Interface**: Real-time monitoring via LEDs and 7-segment displays
- **Target Clock**: 50MHz on Basys 3 FPGA
- **ISA Support**: Core RISC-V instructions (R-type, I-type, S-type, B-type, J-type, U-type)

## Supported Instructions

| Type | Instructions | Description |
|------|-------------|-------------|
| R-type | ADD, SUB, AND, OR, XOR | Register-register operations |
| I-type | ADDI, ANDI, ORI, XORI, LW | Immediate and load operations |
| S-type | SW | Store operations |
| B-type | BEQ, BNE | Branch operations |
| J-type | JAL | Jump and link |
| U-type | LUI | Load upper immediate |

## Architecture

### Pipeline Stages
1. **IF (Instruction Fetch)**: PC management and instruction memory access
2. **ID (Instruction Decode)**: Instruction decoding, register file access, control signal generation
3. **EX (Execute)**: ALU operations, branch target calculation
4. **MEM (Memory)**: Data memory access for load/store operations
5. **WB (Write-Back)**: Register file write-back with source selection

### Key Components
- **Register File**: 32 x 32-bit registers with dual read ports
- **ALU**: Supports arithmetic, logical, and comparison operations
- **Control Unit**: Generates control signals based on instruction opcode/funct fields
- **Hazard Unit**: Detects data hazards and generates forwarding/stall signals
- **Forwarding Unit**: Implements data forwarding to resolve hazards
- **Immediate Generator**: Extracts and sign-extends immediate values

## File Structure

```
design_sources/
├── riscv_pipeline_top.sv      # top-level pipeline with all stages
├── riscv_if_stage.sv          # instruction fetch stage
├── riscv_id_stage.sv          # instruction decode stage  
├── riscv_ex_stage.sv          # execute stage
├── riscv_mem_stage.sv         # memory stage
├── riscv_wb_stage.sv          # write-back stage
└── riscv_hazard_unit.sv       # hazard detection and forwarding

constraint_sources/
└── basys3.xdc                 # pin assignments and timing constraints

simulation_sources/
├── riscv_pipeline_top_tb.sv   # full pipeline testbench
└── riscv_if_stage_tb.sv       # instruction fetch stage testbench
```

## FPGA Implementation

### Hardware Requirements
- **Board**: Basys 3 (Artix-7 XC7A35T)
- **Clock**: 50MHz system clock
- **Memory**: 4KB instruction + 4KB data (block RAM)
- **I/O**: 16 LEDs, 4x 7-segment display, 1 reset button

### Debug Interface
- **LEDs 0-7**: Program Counter (PC) lower 8 bits
- **LED 8**: Register write enable indicator
- **LEDs 9-13**: Destination register address
- **LEDs 14-15**: Current instruction lower 2 bits
- **7-Segment Display**: Program Counter upper bits

### Memory Map
- **Instruction Memory**: 0x00000000 - 0x00000FFF (4KB)
- **Data Memory**: 0x00000000 - 0x00000FFF (4KB)

## Getting Started

### Prerequisites
- Xilinx Vivado (tested with 2023.2)
- Basys 3 FPGA development board
- USB cable for programming

### Build and Run
1. **Create Project**: Open Vivado and create new project
2. **Add Sources**: Import all `.sv` files from `design_sources/` directory
3. **Add Constraints**: Import `basys3.xdc` from `constraint_sources/`
4. **Add Testbenches**: Import testbench files from `simulation_sources/` 
5. **Simulate**: Run behavioral simulation to verify functionality
6. **Synthesize**: Run synthesis (check for timing closure)
7. **Implement**: Run implementation and generate bitstream
8. **Program**: Connect Basys 3 board and program FPGA (ready for implementation)

### Test Program
The instruction memory is pre-loaded with a simple test program:
```assembly
ADDI x1, x2, 3      # x1 = x2 + 3
ADDI x2, x1, 4      # x2 = x1 + 4  
ADD  x3, x1, x2     # x3 = x1 + x2
SUB  x4, x1, x2     # x4 = x1 - x2
AND  x5, x1, x2     # x5 = x1 & x2
OR   x6, x1, x2     # x6 = x1 | x2
XOR  x7, x1, x2     # x7 = x1 ^ x2
```

## Performance

- **Clock Frequency**: 50MHz target (20ns period)
- **Throughput**: Up to 1 instruction per cycle (with proper forwarding)
- **Latency**: 5 cycles for instruction completion
- **Resource Usage**: ~2000 LUTs, 16 Block RAMs (estimated for Artix-7)

## Verification

The design has been verified through:
- **Functional Simulation**: Testbench verification of individual modules (riscv_if_stage_tb.sv)
- **Integration Testing**: Full pipeline simulation with sample programs (riscv_pipeline_top_tb.sv)
- **Synthesis Validation**: Design successfully synthesizes with proper timing constraints
- **Waveform Analysis**: VCD file generation for detailed signal inspection
- **Ready for Hardware**: Constraint file configured for Basys 3 FPGA implementation

## Future Enhancements

- [ ] Branch prediction for improved performance
- [ ] Cache memory implementation
- [ ] Floating-point unit integration
- [ ] Exception and interrupt handling
- [ ] Additional RISC-V instruction extensions

## References

- [RISC-V Instruction Set Manual](https://riscv.org/technical/specifications/)
- [Computer Organization and Design: RISC-V Edition](https://www.elsevier.com/books/computer-organization-and-design-risc-v-edition/patterson/978-0-12-812275-4)
- [Basys 3 Reference Manual](https://digilent.com/reference/programmable-logic/basys-3/reference-manual)
