`timescale 1ns/1ps

module tb_cpu_single_cycle;

    reg clk, rst;

    cpu_single_cycle uut (
        .clk (clk),
        .rst (rst)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    wire [31:0] pc      = uut.pc_out;
    wire [31:0] instr   = uut.instr;
    wire [31:0] alu_res = uut.alu_result;
    wire [31:0] wb      = uut.wb_data;

    integer i;

    initial begin
        rst = 1;
        repeat(2) @(posedge clk);
        rst = 0;

        repeat(10) @(posedge clk);
        #1;

        $display("=== Register File Dump ===");
        for (i = 0; i < 8; i = i + 1)
            $display("x%0d = %0d (0x%h)", i,
                $signed(uut.u_reg_file.registers[i]),
                uut.u_reg_file.registers[i]);

        $display("=== Data Memory[0] ===");
        $display("mem[0] = 0x%h%h%h%h",
            uut.u_data_mem.mem[3],
            uut.u_data_mem.mem[2],
            uut.u_data_mem.mem[1],
            uut.u_data_mem.mem[0]);

        $finish;
    end

endmodule