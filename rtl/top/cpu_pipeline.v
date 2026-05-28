`timescale 1ns/1ps
module cpu_pipeline (
    input wire clk,
    input wire rst
);

    // ── IF stage wires ──────────────────────────────────────
    wire [31:0] if_pc, if_pc_plus4, if_instr;
    wire [31:0] pc_next;
    wire        stall, if_id_flush, id_ex_flush_hazard;

    // ── IF/ID register outputs ──────────────────────────────
    wire [31:0] id_pc, id_instr;

    // ── ID stage wires ──────────────────────────────────────
    wire [6:0]  id_opcode  = id_instr[6:0];
    wire [4:0]  id_rd      = id_instr[11:7];
    wire [2:0]  id_funct3  = id_instr[14:12];
    wire [4:0]  id_rs1     = id_instr[19:15];
    wire [4:0]  id_rs2     = id_instr[24:20];
    wire [6:0]  id_funct7  = id_instr[31:25];
    wire [31:0] id_rs1_data, id_rs2_data, id_imm;
    wire        id_reg_write; wire [3:0] id_alu_op;
    wire        id_alu_src, id_mem_read, id_mem_write;
    wire [1:0]  id_mem_size, id_wb_sel;
    wire        id_branch, id_jump;

    // ── ID/EX register outputs ──────────────────────────────
    wire [31:0] ex_pc, ex_rs1_data, ex_rs2_data, ex_imm;
    wire [4:0]  ex_rs1_addr, ex_rs2_addr, ex_rd_addr;
    wire [2:0]  ex_funct3; wire [6:0] ex_funct7, ex_opcode;
    wire        ex_reg_write; wire [3:0] ex_alu_op;
    wire        ex_alu_src, ex_mem_read, ex_mem_write;
    wire [1:0]  ex_mem_size, ex_wb_sel;
    wire        ex_branch, ex_jump;

    // ── EX stage wires ──────────────────────────────────────
    wire [1:0]  forward_a, forward_b;
    wire [31:0] alu_op_a, alu_op_b_pre, alu_op_b;
    wire [31:0] ex_alu_result; wire ex_alu_zero;
    wire [31:0] ex_pc_plus4 = ex_pc + 4;
    wire [31:0] ex_branch_target = ex_pc + ex_imm;
    wire        ex_take_branch;
    wire [31:0] wb_data;  // from MEM/WB stage

    // ── EX/MEM register outputs ─────────────────────────────
    wire [31:0] mem_pc_plus4, mem_alu_result, mem_rs2_data;
    wire [4:0]  mem_rd_addr; wire [2:0] mem_funct3;
    wire        mem_alu_zero, mem_reg_write;
    wire        mem_mem_read, mem_mem_write;
    wire [1:0]  mem_mem_size, mem_wb_sel;
    wire        mem_branch, mem_jump;
    wire        mem_take_branch; wire [31:0] mem_branch_target;

    // ── MEM stage wires ─────────────────────────────────────
    wire [31:0] mem_read_data;

    // ── MEM/WB register outputs ─────────────────────────────
    wire [31:0] wb_alu_result, wb_mem_data, wb_pc_plus4;
    wire [4:0]  wb_rd_addr;
    wire        wb_reg_write; wire [1:0] wb_wb_sel;

    // ── Writeback mux ────────────────────────────────────────
    assign wb_data = (wb_wb_sel == 2'b01) ? wb_mem_data  :
                     (wb_wb_sel == 2'b10) ? wb_pc_plus4  :
                     wb_alu_result;

    // ── Branch/flush logic ───────────────────────────────────
    assign ex_take_branch = ex_branch & (
        (ex_funct3 == 3'b000 &  ex_alu_zero)       |
        (ex_funct3 == 3'b001 & ~ex_alu_zero)       |
        (ex_funct3 == 3'b100 &  ex_alu_result[0])  |
        (ex_funct3 == 3'b101 & ~ex_alu_result[0])  |
        (ex_funct3 == 3'b110 &  ex_alu_result[0])  |
        (ex_funct3 == 3'b111 & ~ex_alu_result[0])
    );

    wire ex_flush    = ex_take_branch | ex_jump;
    assign if_id_flush = ex_flush;

    assign pc_next = (ex_jump & ex_opcode == 7'b1100111) ?
                         (ex_rs1_data + ex_imm) :
                     ex_take_branch ? ex_branch_target :
                     ex_jump        ? ex_branch_target :
                     if_pc_plus4;

    // ── Forwarding mux ───────────────────────────────────────
    assign alu_op_a    = (forward_a == 2'b10) ? mem_alu_result :
                         (forward_a == 2'b01) ? wb_data        :
                         ex_rs1_data;

    assign alu_op_b_pre = (forward_b == 2'b10) ? mem_alu_result :
                          (forward_b == 2'b01) ? wb_data        :
                          ex_rs2_data;

    assign alu_op_b = ex_alu_src ? ex_imm : alu_op_b_pre;

    // ── Module instantiations ────────────────────────────────

    pc u_pc (
        .clk(clk), .rst(rst), .stall(stall),
        .pc_next(pc_next), .pc_out(if_pc)
    );

    pc_adder u_pc_adder (
        .pc_in(if_pc), .pc_plus4(if_pc_plus4)
    );

    instr_mem u_imem (
        .clk(clk), .addr(if_pc), .instr(if_instr)
    );

    if_id_reg u_if_id (
        .clk(clk), .rst(rst),
        .flush(if_id_flush), .stall(stall),
        .pc_in(if_pc), .instr_in(if_instr),
        .pc_out(id_pc), .instr_out(id_instr)
    );

    control_unit u_ctrl (
        .opcode(id_opcode), .funct3(id_funct3), .funct7(id_funct7),
        .reg_write(id_reg_write), .alu_op(id_alu_op),
        .alu_src(id_alu_src), .mem_read(id_mem_read),
        .mem_write(id_mem_write), .mem_size(id_mem_size),
        .wb_sel(id_wb_sel), .branch(id_branch),
        .jump(id_jump), .pc_src()
    );

    imm_gen u_imm (.instr(id_instr), .imm_out(id_imm));

    reg_file u_regfile (
        .clk(clk), .rst(rst),
        .rs1_addr(id_rs1), .rs1_data(id_rs1_data),
        .rs2_addr(id_rs2), .rs2_data(id_rs2_data),
        .reg_write(wb_reg_write), .rd_addr(wb_rd_addr),
        .rd_data(wb_data)
    );

    hazard_unit u_hazard (
        .id_rs1(id_rs1), .id_rs2(id_rs2),
        .ex_rd(ex_rd_addr), .ex_mem_read(ex_mem_read),
        .stall(stall), .id_ex_flush(id_ex_flush_hazard)
    );

    id_ex_reg u_id_ex (
        .clk(clk), .rst(rst),
        .flush(id_ex_flush_hazard),
        .pc_in(id_pc), .rs1_data_in(id_rs1_data),
        .rs2_data_in(id_rs2_data), .imm_in(id_imm),
        .rs1_addr_in(id_rs1), .rs2_addr_in(id_rs2),
        .rd_addr_in(id_rd), .funct3_in(id_funct3),
        .funct7_in(id_funct7), .opcode_in(id_opcode),
        .reg_write_in(id_reg_write), .alu_op_in(id_alu_op),
        .alu_src_in(id_alu_src), .mem_read_in(id_mem_read),
        .mem_write_in(id_mem_write), .mem_size_in(id_mem_size),
        .wb_sel_in(id_wb_sel), .branch_in(id_branch),
        .jump_in(id_jump),
        .pc_out(ex_pc), .rs1_data_out(ex_rs1_data),
        .rs2_data_out(ex_rs2_data), .imm_out(ex_imm),
        .rs1_addr_out(ex_rs1_addr), .rs2_addr_out(ex_rs2_addr),
        .rd_addr_out(ex_rd_addr), .funct3_out(ex_funct3),
        .funct7_out(ex_funct7), .opcode_out(ex_opcode),
        .reg_write_out(ex_reg_write), .alu_op_out(ex_alu_op),
        .alu_src_out(ex_alu_src), .mem_read_out(ex_mem_read),
        .mem_write_out(ex_mem_write), .mem_size_out(ex_mem_size),
        .wb_sel_out(ex_wb_sel), .branch_out(ex_branch),
        .jump_out(ex_jump)
    );

    forwarding_unit u_fwd (
        .ex_rs1(ex_rs1_addr), .ex_rs2(ex_rs2_addr),
        .exmem_rd(mem_rd_addr), .exmem_regwrite(mem_reg_write),
        .memwb_rd(wb_rd_addr),  .memwb_regwrite(wb_reg_write),
        .forward_a(forward_a),  .forward_b(forward_b)
    );

    wire [31:0] ex_alu_a = (ex_opcode == 7'b0110111) ? 32'b0   :
                           (ex_opcode == 7'b0010111) ? ex_pc   :
                           alu_op_a;

    alu u_alu (
        .operand_a(ex_alu_a), .operand_b(alu_op_b),
        .alu_op(ex_alu_op),
        .result(ex_alu_result), .zero(ex_alu_zero)
    );

    ex_mem_reg u_ex_mem (
        .clk(clk), .rst(rst), .flush(1'b0),
        .pc_plus4_in(ex_pc_plus4), .alu_result_in(ex_alu_result),
        .rs2_data_in(alu_op_b_pre), .rd_addr_in(ex_rd_addr),
        .funct3_in(ex_funct3), .alu_zero_in(ex_alu_zero),
        .reg_write_in(ex_reg_write), .mem_read_in(ex_mem_read),
        .mem_write_in(ex_mem_write), .mem_size_in(ex_mem_size),
        .wb_sel_in(ex_wb_sel), .branch_in(ex_branch),
        .jump_in(ex_jump), .take_branch_in(ex_take_branch),
        .branch_target_in(ex_branch_target),
        .pc_plus4_out(mem_pc_plus4), .alu_result_out(mem_alu_result),
        .rs2_data_out(mem_rs2_data), .rd_addr_out(mem_rd_addr),
        .funct3_out(mem_funct3), .alu_zero_out(mem_alu_zero),
        .reg_write_out(mem_reg_write), .mem_read_out(mem_mem_read),
        .mem_write_out(mem_mem_write), .mem_size_out(mem_mem_size),
        .wb_sel_out(mem_wb_sel), .branch_out(mem_branch),
        .jump_out(mem_jump), .take_branch_out(mem_take_branch),
        .branch_target_out(mem_branch_target)
    );

    data_mem u_dmem (
        .clk(clk), .mem_read(mem_mem_read),
        .mem_write(mem_mem_write), .mem_size(mem_mem_size),
        .mem_signed(mem_funct3[2] == 0),
        .addr(mem_alu_result), .write_data(mem_rs2_data),
        .read_data(mem_read_data)
    );

    mem_wb_reg u_mem_wb (
        .clk(clk), .rst(rst),
        .alu_result_in(mem_alu_result), .mem_data_in(mem_read_data),
        .pc_plus4_in(mem_pc_plus4), .rd_addr_in(mem_rd_addr),
        .reg_write_in(mem_reg_write), .wb_sel_in(mem_wb_sel),
        .alu_result_out(wb_alu_result), .mem_data_out(wb_mem_data),
        .pc_plus4_out(wb_pc_plus4), .rd_addr_out(wb_rd_addr),
        .reg_write_out(wb_reg_write), .wb_sel_out(wb_wb_sel)
    );

endmodule