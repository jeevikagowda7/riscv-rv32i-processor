// ============================================================
// Testbench : tb_pc
// Tests : reset behavior, sequential increment, stall, 
//         branch target jump
// ============================================================

`timescale 1ns/1ps

module tb_pc;

    // ---- inputs (driven by testbench) ----
    reg        clk;
    reg        rst;
    reg        stall;
    reg [31:0] pc_next;

    // ---- output (observed) ----
    wire [31:0] pc_out;

    // ---- instantiate the PC ----
    pc uut (
        .clk     (clk),
        .rst     (rst),
        .stall   (stall),
        .pc_next (pc_next),
        .pc_out  (pc_out)
    );

    // ---- clock: 10ns period ----
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- stimulus ----
    initial begin
        $dumpfile("sim/tb_pc.vcd");   // waveform output file
        $dumpvars(0, tb_pc);

        // --- TEST 1: Reset ---
        rst = 1; stall = 0; pc_next = 32'hDEADBEEF;
        @(posedge clk); #1;
        $display("T1 RESET    | pc_out = %h (expect 00000000)", pc_out);

        // --- TEST 2: Sequential increment ---
        rst = 0; pc_next = 32'h00000004;
        @(posedge clk); #1;
        $display("T2 SEQ +4   | pc_out = %h (expect 00000004)", pc_out);

        pc_next = 32'h00000008;
        @(posedge clk); #1;
        $display("T3 SEQ +4   | pc_out = %h (expect 00000008)", pc_out);

        // --- TEST 3: Branch jump ---
        pc_next = 32'h00400080;       // simulate branch target
        @(posedge clk); #1;
        $display("T4 BRANCH   | pc_out = %h (expect 00400080)", pc_out);

        // --- TEST 4: Stall (PC must not change) ---
        stall = 1; pc_next = 32'hFFFFFFFF;
        @(posedge clk); #1;
        $display("T5 STALL    | pc_out = %h (expect 00400080)", pc_out);

        stall = 0;
        @(posedge clk); #1;
        $display("T6 UNSTALL  | pc_out = %h (expect ffffffff)", pc_out);

        $display("-----------------------------");
        $display("PC testbench complete.");
        $finish;
    end

endmodule