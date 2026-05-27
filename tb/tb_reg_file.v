// ============================================================
// Testbench : tb_reg_file
// Tests : reset, write+read, x0 hardwired zero,
//         two simultaneous reads, write enable gating
// ============================================================

`timescale 1ns/1ps

module tb_reg_file;

    reg        clk, rst, reg_write;
    reg [4:0]  rs1_addr, rs2_addr, rd_addr;
    reg [31:0] rd_data;

    wire [31:0] rs1_data, rs2_data;

    reg_file uut (
        .clk       (clk),
        .rst       (rst),
        .rs1_addr  (rs1_addr),
        .rs1_data  (rs1_data),
        .rs2_addr  (rs2_addr),
        .rs2_data  (rs2_data),
        .reg_write (reg_write),
        .rd_addr   (rd_addr),
        .rd_data   (rd_data)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_reg_file.vcd");
        $dumpvars(0, tb_reg_file);

        // --- Reset ---
        rst = 1; reg_write = 0;
        rs1_addr = 0; rs2_addr = 0;
        rd_addr = 0; rd_data = 0;
        @(posedge clk); #1;
        rst = 0;

        // --- TEST 1: Write 42 to x1, read it back ---
        reg_write = 1; rd_addr = 5'd1; rd_data = 32'd42;
        @(posedge clk); #1;
        reg_write = 0;
        rs1_addr = 5'd1;
        #1;
        $display("T1 WRITE/READ  | x1 = %0d (expect 42)", rs1_data);

        // --- TEST 2: Write 100 to x2, read both x1 and x2 ---
        reg_write = 1; rd_addr = 5'd2; rd_data = 32'd100;
        @(posedge clk); #1;
        reg_write = 0;
        rs1_addr = 5'd1; rs2_addr = 5'd2;
        #1;
        $display("T2 DUAL READ   | x1 = %0d (expect 42), x2 = %0d (expect 100)",
                  rs1_data, rs2_data);

        // --- TEST 3: x0 hardwired to zero ---
        reg_write = 1; rd_addr = 5'd0; rd_data = 32'hDEADBEEF;
        @(posedge clk); #1;
        reg_write = 0;
        rs1_addr = 5'd0;
        #1;
        $display("T3 x0 HARDWIRE | x0 = %0d (expect 0)", rs1_data);

        // --- TEST 4: Write enable gating ---
        reg_write = 0; rd_addr = 5'd3; rd_data = 32'd999;
        @(posedge clk); #1;
        rs1_addr = 5'd3;
        #1;
        $display("T4 WE GATED    | x3 = %0d (expect 0, write disabled)", rs1_data);

        // --- TEST 5: Write max value to x31 ---
        reg_write = 1; rd_addr = 5'd31; rd_data = 32'hFFFFFFFF;
        @(posedge clk); #1;
        reg_write = 0;
        rs1_addr = 5'd31;
        #1;
        $display("T5 MAX VALUE   | x31 = %h (expect ffffffff)", rs1_data);

        $display("-----------------------------");
        $display("Register File testbench complete.");
        $finish;
    end

endmodule