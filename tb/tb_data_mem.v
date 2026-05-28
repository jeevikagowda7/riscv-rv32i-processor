`timescale 1ns/1ps

module tb_data_mem;

    reg        clk, mem_read, mem_write, mem_signed;
    reg [1:0]  mem_size;
    reg [31:0] addr, write_data;
    wire[31:0] read_data;

    data_mem uut (
        .clk        (clk),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_size   (mem_size),
        .mem_signed (mem_signed),
        .addr       (addr),
        .write_data (write_data),
        .read_data  (read_data)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin

        mem_read = 0; mem_write = 0;
        mem_signed = 0; mem_size = 2'b10;
        addr = 0; write_data = 0;

        // --- TEST 1: Write word 0xDEADBEEF to addr 0, read it back ---
        mem_write = 1; mem_size = 2'b10;
        addr = 32'd0; write_data = 32'hDEADBEEF;
        @(posedge clk); #1;
        mem_write = 0; mem_read = 1;
        addr = 32'd0;
        @(posedge clk); #1;
        $display("T1 SW/LW     | read = 0x%h (expect 0xdeadbeef)", read_data);

        // --- TEST 2: Write word to addr 4, read back ---
        mem_write = 1; mem_read = 0;
        addr = 32'd4; write_data = 32'h12345678;
        @(posedge clk); #1;
        mem_write = 0; mem_read = 1;
        addr = 32'd4;
        @(posedge clk); #1;
        $display("T2 SW/LW     | read = 0x%h (expect 0x12345678)", read_data);

        // --- TEST 3: Write byte 0xAB to addr 8, read unsigned ---
        mem_write = 1; mem_size = 2'b00;
        addr = 32'd8; write_data = 32'h000000AB;
        @(posedge clk); #1;
        mem_write = 0; mem_read = 1;
        mem_signed = 0;
        addr = 32'd8;
        @(posedge clk); #1;
        $display("T3 SB/LBU    | read = 0x%h (expect 0x000000ab)", read_data);

        // --- TEST 4: Read same byte signed (0xAB = negative) ---
        mem_read = 1; mem_signed = 1; mem_size = 2'b00;
        addr = 32'd8;
        @(posedge clk); #1;
        $display("T4 LB signed | read = %0d (expect -85)", $signed(read_data));

        // --- TEST 5: Write halfword 0x1234 to addr 12 ---
        mem_write = 1; mem_read = 0;
        mem_size = 2'b01; mem_signed = 0;
        addr = 32'd12; write_data = 32'h00001234;
        @(posedge clk); #1;
        mem_write = 0; mem_read = 1;
        addr = 32'd12;
        @(posedge clk); #1;
        $display("T5 SH/LHU    | read = 0x%h (expect 0x00001234)", read_data);

        $display("-----------------------------");
        $display("Data Memory testbench complete.");
        $finish;
    end

endmodule