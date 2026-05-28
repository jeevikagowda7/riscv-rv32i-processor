`timescale 1ns/1ps

module tb_control_unit;

    reg  [6:0] opcode;
    reg  [2:0] funct3;
    reg  [6:0] funct7;

    wire        reg_write, alu_src, mem_read, mem_write, branch, jump, pc_src;
    wire [3:0]  alu_op;
    wire [1:0]  mem_size, wb_sel;

    control_unit uut (
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

    initial begin

        // ADD (R-type)
        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("ADD    | reg_write=%b alu_src=%b alu_op=%b (expect 1,0,0000)",
                  reg_write, alu_src, alu_op);

        // ADDI (I-ALU)
        opcode = 7'b0010011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("ADDI   | reg_write=%b alu_src=%b alu_op=%b (expect 1,1,0000)",
                  reg_write, alu_src, alu_op);

        // LW (I-Load)
        opcode = 7'b0000011; funct3 = 3'b010; funct7 = 7'b0000000; #10;
        $display("LW     | mem_read=%b wb_sel=%b alu_src=%b (expect 1,01,1)",
                  mem_read, wb_sel, alu_src);

        // SW (S-type)
        opcode = 7'b0100011; funct3 = 3'b010; funct7 = 7'b0000000; #10;
        $display("SW     | mem_write=%b reg_write=%b (expect 1,0)",
                  mem_write, reg_write);

        // BEQ (B-type)
        opcode = 7'b1100011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("BEQ    | branch=%b reg_write=%b alu_op=%b (expect 1,0,0001)",
                  branch, reg_write, alu_op);

        // JAL (J-type)
        opcode = 7'b1101111; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("JAL    | jump=%b reg_write=%b wb_sel=%b (expect 1,1,10)",
                  jump, reg_write, wb_sel);

        // LUI (U-type)
        opcode = 7'b0110111; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("LUI    | reg_write=%b alu_src=%b (expect 1,1)",
                  reg_write, alu_src);

        $display("-----------------------------");
        $display("Control Unit testbench complete.");
        $finish;
    end

endmodule