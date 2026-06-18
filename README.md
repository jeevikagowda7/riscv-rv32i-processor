# riscv-rv32i-processor# RV32I Pipelined Processor — RTL Design in Verilog

A fully functional 5-stage pipelined RISC-V (RV32I) processor implemented 
in Verilog at the Register Transfer Level (RTL). Designed from scratch, 
verified through behavioral simulation in Vivado 2025.1.

---

## Architecture Overview
IF → [IF/ID] → ID → [ID/EX] → EX → [EX/MEM] → MEM → [MEM/WB] → WB

5-stage pipeline with:
- **Forwarding Unit** — resolves data hazards without stalling
- **Hazard Detection Unit** — detects load-use hazards, inserts bubbles
- **Branch Flush** — flushes pipeline on taken branches

---

## Supported Instructions (RV32I Base ISA)

| Format | Instructions |
|--------|-------------|
| R-type | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU |
| I-type ALU | ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU |
| I-type Load | LW, LH, LB, LHU, LBU |
| S-type | SW, SH, SB |
| B-type | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| U-type | LUI, AUIPC |
| J-type | JAL, JALR |

---

## Module Structure
rtl/

├── fetch/

│   ├── pc.v              # Program Counter with stall support

│   ├── pc_adder.v        # PC + 4 combinational adder

│   ├── instr_mem.v       # Instruction memory (async read)

│   └── if_id_reg.v       # IF/ID pipeline register

├── decode/

│   ├── control_unit.v    # Instruction decoder, control signals

│   ├── imm_gen.v         # Immediate generator (all formats)

│   ├── reg_file.v        # 32x32-bit register file

│   ├── id_ex_reg.v       # ID/EX pipeline register

│   └── hazard_unit.v     # Load-use hazard detection

├── execute/

│   ├── alu.v             # 10-operation ALU

│   ├── forwarding_unit.v # Data hazard forwarding

│   └── ex_mem_reg.v      # EX/MEM pipeline register

├── memory/

│   ├── data_mem.v        # Byte-addressable data memory

│   └── mem_wb_reg.v      # MEM/WB pipeline register

└── top/

├── cpu_single_cycle.v # Single-cycle integration

└── cpu_pipeline.v     # Pipelined CPU top module

tb/

├── tb_pc.v

├── tb_instr_mem.v

├── tb_reg_file.v

├── tb_alu.v

├── tb_control_unit.v

├── tb_imm_gen.v

├── tb_data_mem.v

├── tb_cpu_single_cycle.v

├── tb_cpu_pipeline.v

└── program.hex

---

## Simulation Results

### Test Program
```asm
ADDI x1, x0, 5      # x1 = 5
ADDI x2, x0, 10     # x2 = 10
ADD  x3, x1, x2     # x3 = 15
SW   x3, 0(x0)      # mem[0] = 15
LW   x4, 0(x0)      # x4 = 15
JAL  x0, 0          # halt
```

### Register File Output
| Register | Value | Instruction |
|----------|-------|-------------|
| x1 | 5 | ADDI x1, x0, 5 |
| x2 | 10 | ADDI x2, x0, 10 |
| x3 | 15 | ADD x3, x1, x2 |
| x4 | 15 | LW x4, 0(x0) |
| mem[0] | 0x0000000f | SW x3, 0(x0) |

### Pipelined CPU Waveform
![Pipeline Waveform](docs/pipeline_waveform.png)

### Single-Cycle CPU Waveform
![Single Cycle Waveform](docs/single_cycle_waveform.png)

---

## Hazard Handling

### Data Hazards — Forwarding
When an instruction in EX needs a result still in the pipeline:
- **EX→EX forward**: result forwarded from EX/MEM register
- **MEM→EX forward**: result forwarded from MEM/WB register
- No stall needed for ALU-to-ALU dependencies

### Load-Use Hazard — Stall + Bubble
When a load is immediately followed by a dependent instruction:
- PC and IF/ID register are stalled for 1 cycle
- A NOP bubble is inserted into the ID/EX register
- Forwarding then handles the rest

### Control Hazards — Branch Flush
On a taken branch or jump:
- Branch target computed in EX stage
- IF/ID and ID/EX registers flushed (2-cycle penalty)
- PC redirected to branch target

---

## Tools Used

| Tool | Version | Purpose |
|------|---------|---------|
| Vivado | 2025.1 | Simulation + Synthesis |
| VS Code | Latest | RTL editing |
| Git | Latest | Version control |

---

## How to Simulate

1. Clone the repo
2. Open Vivado → Open Project → select `riscv_rv32i/riscv_rv32i.xpr`
3. Copy `tb/program.hex` to the xsim working directory
4. Set `tb_cpu_pipeline` as simulation top
5. Run Behavioral Simulation

---

## Key Design Decisions

**Why Harvard Architecture?**
Separate instruction and data memories eliminate structural hazards between fetch and memory stages without any additional hardware.

**Why async instruction memory read?**
In a single-cycle and pipelined design, the PC feeds the instruction memory combinationally so the instruction is available at the start of the decode stage in the same cycle.

**Why forwarding over stalling?**
Forwarding adds ~3 muxes but eliminates stall cycles for ALU-ALU dependencies, which are the most common hazard in typical RV32I programs. CPI stays close to 1.

---

## Author

**Jeevika Gowda**  