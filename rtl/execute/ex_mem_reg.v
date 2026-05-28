// ============================================================
// EX/MEM Pipeline Register
// Holds: ALU result, branch info, memory control
// ============================================================
module ex_mem_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire        flush,

    input  wire [31:0] pc_plus4_in,
    input  wire [31:0] alu_result_in,
    input  wire [31:0] rs2_data_in,
    input  wire [4:0]  rd_addr_in,
    input  wire [2:0]  funct3_in,
    input  wire        alu_zero_in,
    input  wire        reg_write_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire [1:0]  mem_size_in,
    input  wire [1:0]  wb_sel_in,
    input  wire        branch_in,
    input  wire        jump_in,
    input  wire        take_branch_in,
    input  wire [31:0] branch_target_in,

    output reg  [31:0] pc_plus4_out,
    output reg  [31:0] alu_result_out,
    output reg  [31:0] rs2_data_out,
    output reg  [4:0]  rd_addr_out,
    output reg  [2:0]  funct3_out,
    output reg         alu_zero_out,
    output reg         reg_write_out,
    output reg         mem_read_out,
    output reg         mem_write_out,
    output reg  [1:0]  mem_size_out,
    output reg  [1:0]  wb_sel_out,
    output reg         branch_out,
    output reg         jump_out,
    output reg         take_branch_out,
    output reg  [31:0] branch_target_out
);
    always @(posedge clk) begin
        if (rst || flush) begin
            pc_plus4_out    <= 0; alu_result_out  <= 0; rs2_data_out    <= 0;
            rd_addr_out     <= 0; funct3_out      <= 0; alu_zero_out    <= 0;
            reg_write_out   <= 0; mem_read_out    <= 0; mem_write_out   <= 0;
            mem_size_out    <= 0; wb_sel_out      <= 0; branch_out      <= 0;
            jump_out        <= 0; take_branch_out <= 0; branch_target_out <= 0;
        end else begin
            pc_plus4_out    <= pc_plus4_in;    alu_result_out  <= alu_result_in;
            rs2_data_out    <= rs2_data_in;    rd_addr_out     <= rd_addr_in;
            funct3_out      <= funct3_in;      alu_zero_out    <= alu_zero_in;
            reg_write_out   <= reg_write_in;   mem_read_out    <= mem_read_in;
            mem_write_out   <= mem_write_in;   mem_size_out    <= mem_size_in;
            wb_sel_out      <= wb_sel_in;      branch_out      <= branch_in;
            jump_out        <= jump_in;        take_branch_out <= take_branch_in;
            branch_target_out <= branch_target_in;
        end
    end
endmodule