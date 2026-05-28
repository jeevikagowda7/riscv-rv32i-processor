// ============================================================
// Module : instr_mem (Instruction Memory)
// Project : RV32I Pipelined Processor
// Description : Asynchronous read for single-cycle CPU.
//               Pre-loaded with program via $readmemh.
// ============================================================

module instr_mem (
    input  wire        clk,
    input  wire [31:0] addr,
    output wire [31:0] instr
);

    reg [31:0] mem [0:255];

    initial begin
        $readmemh("program.hex", mem);
    end

    assign instr = mem[addr[9:2]];

endmodule