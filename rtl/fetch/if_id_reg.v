// ============================================================
// IF/ID Pipeline Register
// Holds: PC and fetched instruction
// ============================================================
module if_id_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire        flush,    // Clear on branch taken
    input  wire        stall,    // Hold on load-use hazard
    input  wire [31:0] pc_in,
    input  wire [31:0] instr_in,
    output reg  [31:0] pc_out,
    output reg  [31:0] instr_out
);
    always @(posedge clk) begin
        if (rst || flush) begin
            pc_out    <= 32'b0;
            instr_out <= 32'b0;  // NOP
        end else if (!stall) begin
            pc_out    <= pc_in;
            instr_out <= instr_in;
        end
    end
endmodule