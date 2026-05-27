// ============================================================
// Module : reg_file (Register File)
// Project : RV32I Pipelined Processor
// Description : 32 x 32-bit registers. Two async read ports,
//               one sync write port. x0 hardwired to zero.
//               Write happens on rising clock edge.
//               Read is combinational (async) for pipeline.
// ============================================================

module reg_file (
    input  wire        clk,
    input  wire        rst,

    // Read port 1 (rs1)
    input  wire [4:0]  rs1_addr,
    output wire [31:0] rs1_data,

    // Read port 2 (rs2)
    input  wire [4:0]  rs2_addr,
    output wire [31:0] rs2_data,

    // Write port (rd) — from WB stage
    input  wire        reg_write,   // Write enable
    input  wire [4:0]  rd_addr,
    input  wire [31:0] rd_data
);

    reg [31:0] registers [0:31];    // 32 x 32-bit register array

    integer i;

    // Synchronous write — on rising edge
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end
        else if (reg_write && rd_addr != 5'b0)
            registers[rd_addr] <= rd_data;  // x0 never written
    end

    // Asynchronous read — combinational
    // x0 always returns 0 regardless of what's stored
    assign rs1_data = (rs1_addr == 5'b0) ? 32'b0 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'b0) ? 32'b0 : registers[rs2_addr];

endmodule