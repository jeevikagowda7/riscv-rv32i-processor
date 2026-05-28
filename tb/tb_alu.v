// ============================================================
// Testbench : tb_alu
// Tests : all 10 ALU operations + zero flag
// ============================================================

`timescale 1ns/1ps

`define ALU_ADD  4'b0000
`define ALU_SUB  4'b0001
`define ALU_AND  4'b0010
`define ALU_OR   4'b0011
`define ALU_XOR  4'b0100
`define ALU_SLL  4'b0101
`define ALU_SRL  4'b0110
`define ALU_SRA  4'b0111
`define ALU_SLT  4'b1000
`define ALU_SLTU 4'b1001

module tb_alu;

    reg  [31:0] operand_a, operand_b;
    reg  [3:0]  alu_op;
    wire [31:0] result;
    wire        zero;

    alu uut (
        .operand_a (operand_a),
        .operand_b (operand_b),
        .alu_op    (alu_op),
        .result    (result),
        .zero      (zero)
    );

    initial begin
        // ADD: 15 + 10 = 25
        operand_a = 32'd15; operand_b = 32'd10; alu_op = `ALU_ADD; #10;
        $display("ADD   | %0d + %0d = %0d (expect 25)", operand_a, operand_b, result);

        // SUB: 15 - 10 = 5
        operand_a = 32'd15; operand_b = 32'd10; alu_op = `ALU_SUB; #10;
        $display("SUB   | %0d - %0d = %0d (expect 5)", operand_a, operand_b, result);

        // AND: 0xFF & 0x0F = 0x0F
        operand_a = 32'hFF; operand_b = 32'h0F; alu_op = `ALU_AND; #10;
        $display("AND   | 0x%h & 0x%h = 0x%h (expect 0x0000000f)", operand_a, operand_b, result);

        // OR: 0xF0 | 0x0F = 0xFF
        operand_a = 32'hF0; operand_b = 32'h0F; alu_op = `ALU_OR; #10;
        $display("OR    | 0x%h | 0x%h = 0x%h (expect 0x000000ff)", operand_a, operand_b, result);

        // XOR: 0xFF ^ 0xFF = 0
        operand_a = 32'hFF; operand_b = 32'hFF; alu_op = `ALU_XOR; #10;
        $display("XOR   | 0x%h ^ 0x%h = %0d (expect 0)", operand_a, operand_b, result);

        // SLL: 1 << 4 = 16
        operand_a = 32'd1; operand_b = 32'd4; alu_op = `ALU_SLL; #10;
        $display("SLL   | 1 << 4 = %0d (expect 16)", result);

        // SRL: 16 >> 2 = 4
        operand_a = 32'd16; operand_b = 32'd2; alu_op = `ALU_SRL; #10;
        $display("SRL   | 16 >> 2 = %0d (expect 4)", result);

        // SRA: -8 >>> 1 = -4 (sign preserved)
        operand_a = 32'hFFFFFFF8; operand_b = 32'd1; alu_op = `ALU_SRA; #10;
        $display("SRA   | -8 >>> 1 = %0d (expect -4)", $signed(result));

        // SLT: 5 < 10 = 1 (signed)
        operand_a = 32'd5; operand_b = 32'd10; alu_op = `ALU_SLT; #10;
        $display("SLT   | 5 < 10 = %0d (expect 1)", result);

        // SLTU: big unsigned > small = 0
        operand_a = 32'hFFFFFFFF; operand_b = 32'd1; alu_op = `ALU_SLTU; #10;
        $display("SLTU  | 0xFFFFFFFF < 1 = %0d (expect 0)", result);

        // ZERO flag: 5 - 5 = 0
        operand_a = 32'd5; operand_b = 32'd5; alu_op = `ALU_SUB; #10;
        $display("ZERO  | 5 - 5 = %0d, zero flag = %0d (expect result=0, flag=1)", result, zero);

        $display("-----------------------------");
        $display("ALU testbench complete.");
        $finish;
    end

endmodule