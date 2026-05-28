// ============================================================
// Module : control_unit
// Project : RV32I Pipelined Processor
// Description : Decodes instruction opcode/funct3/funct7 and
//               generates control signals for all pipeline
//               stages. Pure combinational logic.
// ============================================================

module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,

    // Register file control
    output reg        reg_write,    // Enable write to rd

    // ALU control
    output reg  [3:0] alu_op,       // ALU operation select
    output reg        alu_src,      // 0=rs2, 1=immediate

    // Memory control
    output reg        mem_read,     // Enable data memory read
    output reg        mem_write,    // Enable data memory write
    output reg  [1:0] mem_size,     // 00=byte, 01=half, 10=word

    // Writeback control
    output reg  [1:0] wb_sel,       // 00=ALU, 01=MEM, 10=PC+4

    // Branch/Jump control
    output reg        branch,       // Instruction is a branch
    output reg        jump,         // Instruction is JAL/JALR
    output reg        pc_src        // 0=PC+4, 1=branch/jump target
);

    // Opcode definitions
    localparam R_TYPE  = 7'b0110011;
    localparam I_ALU   = 7'b0010011;
    localparam I_LOAD  = 7'b0000011;
    localparam S_TYPE  = 7'b0100011;
    localparam B_TYPE  = 7'b1100011;
    localparam U_LUI   = 7'b0110111;
    localparam U_AUIPC = 7'b0010111;
    localparam J_JAL   = 7'b1101111;
    localparam J_JALR  = 7'b1100111;

    // ALU op codes (match alu.v defines)
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLL  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;

    always @(*) begin
        // Safe defaults — prevent latches
        reg_write  = 0;
        alu_op     = ALU_ADD;
        alu_src    = 0;
        mem_read   = 0;
        mem_write  = 0;
        mem_size   = 2'b10;
        wb_sel     = 2'b00;
        branch     = 0;
        jump       = 0;
        pc_src     = 0;

        case (opcode)

            R_TYPE: begin
                reg_write = 1;
                alu_src   = 0;     // Use rs2
                wb_sel    = 2'b00; // Write ALU result
                case ({funct7, funct3})
                    10'b0000000_000: alu_op = ALU_ADD;
                    10'b0100000_000: alu_op = ALU_SUB;
                    10'b0000000_111: alu_op = ALU_AND;
                    10'b0000000_110: alu_op = ALU_OR;
                    10'b0000000_100: alu_op = ALU_XOR;
                    10'b0000000_001: alu_op = ALU_SLL;
                    10'b0000000_101: alu_op = ALU_SRL;
                    10'b0100000_101: alu_op = ALU_SRA;
                    10'b0000000_010: alu_op = ALU_SLT;
                    10'b0000000_011: alu_op = ALU_SLTU;
                    default:         alu_op = ALU_ADD;
                endcase
            end

            I_ALU: begin
                reg_write = 1;
                alu_src   = 1;     // Use immediate
                wb_sel    = 2'b00;
                case (funct3)
                    3'b000: alu_op = ALU_ADD;  // ADDI
                    3'b111: alu_op = ALU_AND;  // ANDI
                    3'b110: alu_op = ALU_OR;   // ORI
                    3'b100: alu_op = ALU_XOR;  // XORI
                    3'b001: alu_op = ALU_SLL;  // SLLI
                    3'b010: alu_op = ALU_SLT;  // SLTI
                    3'b011: alu_op = ALU_SLTU; // SLTIU
                    3'b101: alu_op = (funct7[5]) ? ALU_SRA : ALU_SRL; // SRAI/SRLI
                    default: alu_op = ALU_ADD;
                endcase
            end

            I_LOAD: begin
                reg_write = 1;
                alu_src   = 1;      // Base + offset
                alu_op    = ALU_ADD;
                mem_read  = 1;
                wb_sel    = 2'b01;  // Write memory data
                mem_size  = (funct3 == 3'b010) ? 2'b10 :  // LW
                            (funct3[1:0] == 2'b01) ? 2'b01 : // LH/LHU
                             2'b00;                          // LB/LBU
            end

            S_TYPE: begin
                alu_src   = 1;      // Base + offset
                alu_op    = ALU_ADD;
                mem_write = 1;
                mem_size  = (funct3 == 3'b010) ? 2'b10 :
                            (funct3 == 3'b001) ? 2'b01 :
                             2'b00;
            end

            B_TYPE: begin
                alu_src  = 0;
                branch   = 1;
                // ALU does comparison; branch logic checks result
                case (funct3)
                    3'b000: alu_op = ALU_SUB;  // BEQ
                    3'b001: alu_op = ALU_SUB;  // BNE
                    3'b100: alu_op = ALU_SLT;  // BLT
                    3'b101: alu_op = ALU_SLT;  // BGE
                    3'b110: alu_op = ALU_SLTU; // BLTU
                    3'b111: alu_op = ALU_SLTU; // BGEU
                    default: alu_op = ALU_SUB;
                endcase
            end

            U_LUI: begin
                reg_write = 1;
                alu_src   = 1;
                alu_op    = ALU_ADD; // Pass immediate through
                wb_sel    = 2'b00;
            end

            U_AUIPC: begin
                reg_write = 1;
                alu_src   = 1;
                alu_op    = ALU_ADD; // PC + imm
                wb_sel    = 2'b00;
            end

            J_JAL: begin
                reg_write = 1;
                jump      = 1;
                wb_sel    = 2'b10;  // Write PC+4 (return address)
            end

            J_JALR: begin
                reg_write = 1;
                alu_src   = 1;
                alu_op    = ALU_ADD;
                jump      = 1;
                wb_sel    = 2'b10;
            end

        endcase
    end

endmodule