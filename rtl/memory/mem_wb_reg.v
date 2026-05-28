// ============================================================
// MEM/WB Pipeline Register
// Holds: data to write back to register file
// ============================================================
module mem_wb_reg (
    input  wire        clk,
    input  wire        rst,

    input  wire [31:0] alu_result_in,
    input  wire [31:0] mem_data_in,
    input  wire [31:0] pc_plus4_in,
    input  wire [4:0]  rd_addr_in,
    input  wire        reg_write_in,
    input  wire [1:0]  wb_sel_in,

    output reg  [31:0] alu_result_out,
    output reg  [31:0] mem_data_out,
    output reg  [31:0] pc_plus4_out,
    output reg  [4:0]  rd_addr_out,
    output reg         reg_write_out,
    output reg  [1:0]  wb_sel_out
);
    always @(posedge clk) begin
        if (rst) begin
            alu_result_out <= 0; mem_data_out  <= 0;
            pc_plus4_out   <= 0; rd_addr_out   <= 0;
            reg_write_out  <= 0; wb_sel_out    <= 0;
        end else begin
            alu_result_out <= alu_result_in; mem_data_out  <= mem_data_in;
            pc_plus4_out   <= pc_plus4_in;   rd_addr_out   <= rd_addr_in;
            reg_write_out  <= reg_write_in;  wb_sel_out    <= wb_sel_in;
        end
    end
endmodule