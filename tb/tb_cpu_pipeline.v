`timescale 1ns/1ps
module tb_cpu_pipeline;

    reg clk, rst;

    cpu_pipeline uut (
        .clk(clk), .rst(rst)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer i;

    initial begin
        rst = 1;
        repeat(3) @(posedge clk);
        rst = 0;

        // Pipeline needs extra cycles to fill and drain
        repeat(20) @(posedge clk);
        #1;

        $display("=== Pipelined CPU Register Dump ===");
        for (i = 0; i < 8; i = i + 1)
            $display("x%0d = %0d (0x%h)", i,
                $signed(uut.u_regfile.registers[i]),
                uut.u_regfile.registers[i]);

        $display("=== Data Memory[0] ===");
        $display("mem[0] = 0x%h%h%h%h",
            uut.u_dmem.mem[3], uut.u_dmem.mem[2],
            uut.u_dmem.mem[1], uut.u_dmem.mem[0]);

        $display("=== Expected ===");
        $display("x1=5, x2=10, x3=15, x4=15, mem[0]=0x0000000f");
        $finish;
    end

endmodule