// ============================================================
// Module : cpu_single_cycle
// Project : RV32I Pipelined Processor
// Description : Single-cycle RV32I CPU. All modules wired
//               together. One instruction completes per cycle.
//               Foundation for the pipelined version.
// ============================================================

module cpu_single_cycle (
    input wire clk,
    input wire rst
);

    // ─── Fetch stage wires ───────────────────────────────
    wire [31:0] pc_out;         // Current PC
    wire [31:0] pc_plus4;       // PC + 4
    wire [31:0] pc_next;        // Next PC (PC+4 or branch/jump)
    wire [31:0] instr;          // Fetched instruction

    // ─── Decode stage wires ──────────────────────────────
    wire [6:0]  opcode  = instr[6:0];
    wire [4:0]  rd      = instr[11:7];
    wire [2:0]  funct3  = instr[14:12];
    wire [4:0]  rs1     = instr[19:15];
    wire [4:0]  rs2     = instr[24:20];
    wire [6:0]  funct7  = instr[31:25];

    wire [31:0] rs1_data, rs2_data;
    wire [31:0] imm;

    // ─── Control signals ─────────────────────────────────
    wire        reg_write;
    wire [3:0]  alu_op;
    wire        alu_src;
    wire        mem_read;
    wire        mem_write;
    wire [1:0]  mem_size;
    wire [1:0]  wb_sel;
    wire        branch;
    wire        jump;
    wire        pc_src;

    // ─── Execute stage wires ─────────────────────────────
    wire [31:0] alu_operand_b;  // rs2 or immediate
    wire [31:0] alu_result;
    wire        alu_zero;

    // ─── Memory stage wires ──────────────────────────────
    wire [31:0] mem_read_data;

    // ─── Writeback mux ───────────────────────────────────
    wire [31:0] wb_data;

    // ─── Branch/Jump PC logic ────────────────────────────
    wire [31:0] branch_target = pc_out + imm;
    wire        take_branch   = branch & (
                    (funct3 == 3'b000 &  alu_zero) |   // BEQ
                    (funct3 == 3'b001 & ~alu_zero) |   // BNE
                    (funct3 == 3'b100 &  alu_result[0]) | // BLT
                    (funct3 == 3'b101 & ~alu_result[0]) | // BGE
                    (funct3 == 3'b110 &  alu_result[0]) | // BLTU
                    (funct3 == 3'b111 & ~alu_result[0])   // BGEU
                );
    wire        take_jump     = jump;
    wire [31:0] jump_target   = (opcode == 7'b1100111) ?
                                 (rs1_data + imm) :   // JALR: rs1 + imm
                                 (pc_out + imm);      // JAL:  PC  + imm

    assign pc_next = take_jump   ? jump_target   :
                     take_branch ? branch_target :
                     pc_plus4;

    // ─── Module instantiations ───────────────────────────

    pc u_pc (
        .clk     (clk),
        .rst     (rst),
        .stall   (1'b0),        // No stall in single-cycle
        .pc_next (pc_next),
        .pc_out  (pc_out)
    );

    pc_adder u_pc_adder (
        .pc_in    (pc_out),
        .pc_plus4 (pc_plus4)
    );

    instr_mem u_instr_mem (
        .clk   (clk),
        .addr  (pc_out),
        .instr (instr)
    );

    control_unit u_ctrl (
        .opcode    (opcode),
        .funct3    (funct3),
        .funct7    (funct7),
        .reg_write (reg_write),
        .alu_op    (alu_op),
        .alu_src   (alu_src),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .mem_size  (mem_size),
        .wb_sel    (wb_sel),
        .branch    (branch),
        .jump      (jump),
        .pc_src    (pc_src)
    );

    imm_gen u_imm_gen (
        .instr   (instr),
        .imm_out (imm)
    );

    reg_file u_reg_file (
        .clk       (clk),
        .rst       (rst),
        .rs1_addr  (rs1),
        .rs1_data  (rs1_data),
        .rs2_addr  (rs2),
        .rs2_data  (rs2_data),
        .reg_write (reg_write),
        .rd_addr   (rd),
        .rd_data   (wb_data)
    );

    // ALU operand B mux: rs2 or immediate
    assign alu_operand_b = alu_src ? imm : rs2_data;

    // LUI: pass immediate directly, AUIPC: PC + imm
    wire [31:0] alu_operand_a = (opcode == 7'b0110111) ? 32'b0    : // LUI
                                (opcode == 7'b0010111) ? pc_out   : // AUIPC
                                rs1_data;

    alu u_alu (
        .operand_a (alu_operand_a),
        .operand_b (alu_operand_b),
        .alu_op    (alu_op),
        .result    (alu_result),
        .zero      (alu_zero)
    );

    data_mem u_data_mem (
        .clk        (clk),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_size   (mem_size),
        .mem_signed (funct3[2] == 0),  // LB/LH = signed, LBU/LHU = unsigned
        .addr       (alu_result),
        .write_data (rs2_data),
        .read_data  (mem_read_data)
    );

    // Writeback mux: ALU result, memory data, or PC+4
    assign wb_data = (wb_sel == 2'b01) ? mem_read_data :
                     (wb_sel == 2'b10) ? pc_plus4      :
                     alu_result;

endmodule