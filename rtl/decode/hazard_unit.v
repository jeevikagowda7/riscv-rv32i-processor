// ============================================================
// Module : hazard_unit
// Detects load-use hazard — when a load is followed
// immediately by an instruction that uses the loaded value.
// Solution: stall PC and IF/ID, flush ID/EX (insert bubble).
// ============================================================
module hazard_unit (
    input  wire [4:0]  id_rs1,        // RS1 in ID stage
    input  wire [4:0]  id_rs2,        // RS2 in ID stage
    input  wire [4:0]  ex_rd,         // RD in EX stage
    input  wire        ex_mem_read,   // EX stage is a load

    output reg         stall,         // Stall PC + IF/ID
    output reg         id_ex_flush    // Flush ID/EX (bubble)
);
    always @(*) begin
        if (ex_mem_read &&
            (ex_rd == id_rs1 || ex_rd == id_rs2)) begin
            stall      = 1;
            id_ex_flush = 1;
        end else begin
            stall      = 0;
            id_ex_flush = 0;
        end
    end
endmodule