// ============================================================
// Module : imm_gen (Immediate Generator)
// Project : RV32I Pipelined Processor
// Description : Extracts and sign-extends immediates from
//               all RV32I instruction formats.
//               I / S / B / U / J types each encode
//               immediate bits in different positions.
// ============================================================

module imm_gen (
    input  wire [31:0] instr,     // Full 32-bit instruction
    output reg  [31:0] imm_out    // Sign-extended immediate
);

    wire [6:0] opcode = instr[6:0];

    // Opcode definitions
    localparam I_ALU   = 7'b0010011;
    localparam I_LOAD  = 7'b0000011;
    localparam J_JALR  = 7'b1100111;
    localparam S_TYPE  = 7'b0100011;
    localparam B_TYPE  = 7'b1100011;
    localparam U_LUI   = 7'b0110111;
    localparam U_AUIPC = 7'b0010111;
    localparam J_JAL   = 7'b1101111;

    always @(*) begin
        case (opcode)

            // I-type: imm[11:0] = instr[31:20]
            I_ALU, I_LOAD, J_JALR:
                imm_out = {{20{instr[31]}}, instr[31:20]};

            // S-type: imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
            S_TYPE:
                imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-type: imm[12|10:5] = instr[31:25], imm[4:1|11] = instr[11:7]
            // Note: bit 0 is always 0 (instructions are 4-byte aligned)
            B_TYPE:
                imm_out = {{19{instr[31]}}, instr[31], instr[7],
                            instr[30:25], instr[11:8], 1'b0};

            // U-type: imm[31:12] = instr[31:12], lower 12 bits = 0
            U_LUI, U_AUIPC:
                imm_out = {instr[31:12], 12'b0};

            // J-type: imm[20|10:1|11|19:12] scattered across instruction
            // Note: bit 0 is always 0
            J_JAL:
                imm_out = {{11{instr[31]}}, instr[31], instr[19:12],
                            instr[20], instr[30:21], 1'b0};

            default:
                imm_out = 32'b0;
        endcase
    end

endmodule