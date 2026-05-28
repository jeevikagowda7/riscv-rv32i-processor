// ============================================================
// ID/EX Pipeline Register
// Holds: all decoded values and control signals
// ============================================================
module id_ex_reg (
    input  wire        clk,
    input  wire        rst,
    input  wire        flush,

    // Data inputs
    input  wire [31:0] pc_in,
    input  wire [31:0] rs1_data_in,
    input  wire [31:0] rs2_data_in,
    input  wire [31:0] imm_in,
    input  wire [4:0]  rs1_addr_in,
    input  wire [4:0]  rs2_addr_in,
    input  wire [4:0]  rd_addr_in,
    input  wire [2:0]  funct3_in,
    input  wire [6:0]  funct7_in,
    input  wire [6:0]  opcode_in,

    // Control inputs
    input  wire        reg_write_in,
    input  wire [3:0]  alu_op_in,
    input  wire        alu_src_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire [1:0]  mem_size_in,
    input  wire [1:0]  wb_sel_in,
    input  wire        branch_in,
    input  wire        jump_in,

    // Data outputs
    output reg  [31:0] pc_out,
    output reg  [31:0] rs1_data_out,
    output reg  [31:0] rs2_data_out,
    output reg  [31:0] imm_out,
    output reg  [4:0]  rs1_addr_out,
    output reg  [4:0]  rs2_addr_out,
    output reg  [4:0]  rd_addr_out,
    output reg  [2:0]  funct3_out,
    output reg  [6:0]  funct7_out,
    output reg  [6:0]  opcode_out,

    // Control outputs
    output reg         reg_write_out,
    output reg  [3:0]  alu_op_out,
    output reg         alu_src_out,
    output reg         mem_read_out,
    output reg         mem_write_out,
    output reg  [1:0]  mem_size_out,
    output reg  [1:0]  wb_sel_out,
    output reg         branch_out,
    output reg         jump_out
);
    always @(posedge clk) begin
        if (rst || flush) begin
            pc_out        <= 0; rs1_data_out <= 0; rs2_data_out <= 0;
            imm_out       <= 0; rs1_addr_out <= 0; rs2_addr_out <= 0;
            rd_addr_out   <= 0; funct3_out   <= 0; funct7_out   <= 0;
            opcode_out    <= 0; reg_write_out<= 0; alu_op_out   <= 0;
            alu_src_out   <= 0; mem_read_out <= 0; mem_write_out<= 0;
            mem_size_out  <= 0; wb_sel_out   <= 0; branch_out   <= 0;
            jump_out      <= 0;
        end else begin
            pc_out        <= pc_in;        rs1_data_out <= rs1_data_in;
            rs2_data_out  <= rs2_data_in;  imm_out      <= imm_in;
            rs1_addr_out  <= rs1_addr_in;  rs2_addr_out <= rs2_addr_in;
            rd_addr_out   <= rd_addr_in;   funct3_out   <= funct3_in;
            funct7_out    <= funct7_in;    opcode_out   <= opcode_in;
            reg_write_out <= reg_write_in; alu_op_out   <= alu_op_in;
            alu_src_out   <= alu_src_in;   mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in; mem_size_out <= mem_size_in;
            wb_sel_out    <= wb_sel_in;    branch_out   <= branch_in;
            jump_out      <= jump_in;
        end
    end
endmodule