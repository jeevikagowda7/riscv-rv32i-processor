// ============================================================
// Testbench : tb_instr_mem
// Tests : correct instruction fetch at each address,
//         word alignment behavior
// ============================================================

`timescale 1ns/1ps

module tb_instr_mem;

    reg        clk;
    reg [31:0] addr;
    wire[31:0] instr;

    instr_mem uut (
        .clk   (clk),
        .addr  (addr),
        .instr (instr)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_instr_mem.vcd");
        $dumpvars(0, tb_instr_mem);

        // Fetch instruction at address 0 (addi x1,x0,5)
        addr = 32'h00000000;
        @(posedge clk); #1;
        $display("addr=0x%08h | instr=0x%08h (expect 0x00500093)", addr, instr);

        // Fetch instruction at address 4 (addi x2,x0,10)
        addr = 32'h00000004;
        @(posedge clk); #1;
        $display("addr=0x%08h | instr=0x%08h (expect 0x00A00113)", addr, instr);

        // Fetch instruction at address 8 (add x3,x1,x2)
        addr = 32'h00000008;
        @(posedge clk); #1;
        $display("addr=0x%08h | instr=0x%08h (expect 0x00208133)", addr, instr);

        // Fetch instruction at address 12 (sw x3,0(x0))
        addr = 32'h0000000C;
        @(posedge clk); #1;
        $display("addr=0x%08h | instr=0x%08h (expect 0x00302023)", addr, instr);

        // Fetch instruction at address 16 (lw x4,0(x0))
        addr = 32'h00000010;
        @(posedge clk); #1;
        $display("addr=0x%08h | instr=0x%08h (expect 0x00002203)", addr, instr);

        $display("-----------------------------");
        $display("Instruction Memory testbench complete.");
        $finish;
    end

endmodule