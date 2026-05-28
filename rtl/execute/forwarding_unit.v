// ============================================================
// Module : forwarding_unit
// Detects data hazards and selects forwarded values.
// Compares EX stage source registers against
// EX/MEM and MEM/WB destination registers.
// ============================================================
module forwarding_unit (
    input  wire [4:0]  ex_rs1,        // RS1 in EX stage
    input  wire [4:0]  ex_rs2,        // RS2 in EX stage

    input  wire [4:0]  exmem_rd,      // RD in EX/MEM reg
    input  wire        exmem_regwrite,

    input  wire [4:0]  memwb_rd,      // RD in MEM/WB reg
    input  wire        memwb_regwrite,

    output reg  [1:0]  forward_a,     // 00=reg, 01=WB, 10=MEM
    output reg  [1:0]  forward_b
);
    always @(*) begin
        // Forward A
        if (exmem_regwrite && exmem_rd != 0 && exmem_rd == ex_rs1)
            forward_a = 2'b10;  // Forward from EX/MEM
        else if (memwb_regwrite && memwb_rd != 0 && memwb_rd == ex_rs1)
            forward_a = 2'b01;  // Forward from MEM/WB
        else
            forward_a = 2'b00;  // Use register file value

        // Forward B
        if (exmem_regwrite && exmem_rd != 0 && exmem_rd == ex_rs2)
            forward_b = 2'b10;
        else if (memwb_regwrite && memwb_rd != 0 && memwb_rd == ex_rs2)
            forward_b = 2'b01;
        else
            forward_b = 2'b00;
    end
endmodule