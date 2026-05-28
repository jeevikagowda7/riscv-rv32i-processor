`timescale 1ns/1ps

module tb_imm_gen;

    reg  [31:0] instr;
    wire [31:0] imm_out;

    imm_gen uut (
        .instr   (instr),
        .imm_out (imm_out)
    );

    initial begin

        // --- I-type: ADDI x1, x0, 5 ---
        // imm = 5 → instr[31:20] = 12'b000000000101
        // Full instruction: 00500093
        instr = 32'h00500093; #10;
        $display("I-type ADDI  | imm = %0d (expect 5)", $signed(imm_out));

        // --- I-type: ADDI x1, x0, -1 (negative immediate) ---
        // imm = -1 → instr[31:20] = 12'hFFF
        // Full instruction: FFF00093
        instr = 32'hFFF00093; #10;
        $display("I-type -1    | imm = %0d (expect -1)", $signed(imm_out));

        // --- S-type: SW x2, 8(x1) ---
        // imm = 8 → split: imm[11:5]=0000000 imm[4:0]=01000
        // Full instruction: 00212423
        instr = 32'h00212423; #10;
        $display("S-type SW    | imm = %0d (expect 8)", $signed(imm_out));

        // --- B-type: BEQ x1, x2, +8 ---
        // imm = 8 → target offset
        // Full instruction: 00208463
        instr = 32'h00208463; #10;
        $display("B-type BEQ   | imm = %0d (expect 8)", $signed(imm_out));

        // --- U-type: LUI x1, 1 ---
        // imm = 0x00001000 (1 << 12)
        // Full instruction: 000010B7
        instr = 32'h000010B7; #10;
        $display("U-type LUI   | imm = 0x%h (expect 0x00001000)", imm_out);

        // --- J-type: JAL x0, +4 ---
        // imm = 4
        // Full instruction: 0040006F
        instr = 32'h0040006F; #10;
        $display("J-type JAL   | imm = %0d (expect 4)", $signed(imm_out));

        $display("-----------------------------");
        $display("Immediate Generator testbench complete.");
        $finish;
    end

endmodule