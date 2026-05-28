// ============================================================
// Module : alu (Arithmetic Logic Unit)
// Project : RV32I Pipelined Processor
// Description : Combinational ALU supporting all RV32I
//               arithmetic, logical, shift and compare ops.
//               Purely combinational — no clock.
// ============================================================

// ALU operation codes
`define ALU_ADD  4'b0000
`define ALU_SUB  4'b0001
`define ALU_AND  4'b0010
`define ALU_OR   4'b0011
`define ALU_XOR  4'b0100
`define ALU_SLL  4'b0101   // Shift left logical
`define ALU_SRL  4'b0110   // Shift right logical
`define ALU_SRA  4'b0111   // Shift right arithmetic
`define ALU_SLT  4'b1000   // Set less than (signed)
`define ALU_SLTU 4'b1001   // Set less than (unsigned)

module alu (
    input  wire [31:0] operand_a,   // rs1 or PC
    input  wire [31:0] operand_b,   // rs2 or immediate
    input  wire [3:0]  alu_op,      // Operation select
    output reg  [31:0] result,      // ALU result
    output wire        zero         // 1 if result == 0 (used for branches)
);

    assign zero = (result == 32'b0);

    always @(*) begin
        case (alu_op)
            `ALU_ADD  : result = operand_a + operand_b;
            `ALU_SUB  : result = operand_a - operand_b;
            `ALU_AND  : result = operand_a & operand_b;
            `ALU_OR   : result = operand_a | operand_b;
            `ALU_XOR  : result = operand_a ^ operand_b;
            `ALU_SLL  : result = operand_a << operand_b[4:0];
            `ALU_SRL  : result = operand_a >> operand_b[4:0];
            `ALU_SRA  : result = $signed(operand_a) >>> operand_b[4:0];
            `ALU_SLT  : result = ($signed(operand_a) < $signed(operand_b)) ? 32'd1 : 32'd0;
            `ALU_SLTU : result = (operand_a < operand_b) ? 32'd1 : 32'd0;
            default   : result = 32'b0;
        endcase
    end

endmodule