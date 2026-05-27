// ============================================================
// Module : instr_mem (Instruction Memory)
// Project : RV32I Pipelined Processor
// Description : Synchronous read, word-aligned instruction
//               memory. Pre-loaded with program via $readmemh.
//               256 words = 1KB of instruction memory.
// ============================================================

module instr_mem (
    input  wire        clk,
    input  wire [31:0] addr,       // From PC — byte address
    output reg  [31:0] instr       // 32-bit instruction out
);

    reg [31:0] mem [0:255];        // 256 x 32-bit = 1KB memory

    // Load program from hex file at simulation start
    initial begin
        $readmemh("program.hex", mem);
    end

    always @(posedge clk) begin
        instr <= mem[addr[9:2]];   // Word-aligned: byte addr >> 2
    end

endmodule