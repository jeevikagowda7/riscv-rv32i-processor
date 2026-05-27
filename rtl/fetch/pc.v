// ============================================================
// Module : pc (Program Counter)
// Project : RV32I Pipelined Processor
// Description : Holds the address of the next instruction.
//               Updates every clock cycle to PC+4 (sequential)
//               or to a branch/jump target address.
// ============================================================

module pc (
    input  wire        clk,        // Clock
    input  wire        rst,        // Active-high synchronous reset
    input  wire        stall,      // Hold PC (for hazard stalls) — wire up later
    input  wire [31:0] pc_next,    // Next PC value (PC+4 or branch target)
    output reg  [31:0] pc_out      // Current PC value → goes to instruction memory
);

    always @(posedge clk) begin
        if (rst)
            pc_out <= 32'h00000000;   // On reset, start from address 0
        else if (!stall)
            pc_out <= pc_next;        // Only update if not stalled
    end

endmodule