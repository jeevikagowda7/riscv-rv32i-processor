// ============================================================
// Module : data_mem (Data Memory)
// Project : RV32I Pipelined Processor
// Description : Synchronous write, synchronous read.
//               Supports byte, halfword, word access.
//               256 words = 1KB data memory.
//               Harvard architecture — separate from instr mem.
// ============================================================

module data_mem (
    input  wire        clk,
    input  wire        mem_read,    // Read enable
    input  wire        mem_write,   // Write enable
    input  wire [1:0]  mem_size,    // 00=byte 01=half 10=word
    input  wire        mem_signed,  // 1=sign extend on read
    input  wire [31:0] addr,        // Byte address from ALU
    input  wire [31:0] write_data,  // Data to write (from rs2)
    output reg  [31:0] read_data    // Data read out
);

    reg [7:0] mem [0:1023];         // Byte-addressable, 1KB

    integer i;

    // Synchronous write
    always @(posedge clk) begin
        if (mem_write) begin
            case (mem_size)
                2'b10: begin  // Word (SW)
                    mem[addr]   <= write_data[7:0];
                    mem[addr+1] <= write_data[15:8];
                    mem[addr+2] <= write_data[23:16];
                    mem[addr+3] <= write_data[31:24];
                end
                2'b01: begin  // Halfword (SH)
                    mem[addr]   <= write_data[7:0];
                    mem[addr+1] <= write_data[15:8];
                end
                2'b00: begin  // Byte (SB)
                    mem[addr]   <= write_data[7:0];
                end
            endcase
        end
    end

    // Synchronous read
    always @(posedge clk) begin
        if (mem_read) begin
            case (mem_size)
                2'b10:  // LW — full word
                    read_data <= {mem[addr+3], mem[addr+2],
                                  mem[addr+1], mem[addr]};

                2'b01:  // LH / LHU
                    read_data <= mem_signed ?
                        {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]} :
                        {16'b0,                mem[addr+1], mem[addr]};

                2'b00:  // LB / LBU
                    read_data <= mem_signed ?
                        {{24{mem[addr][7]}}, mem[addr]} :
                        {24'b0,              mem[addr]};

                default: read_data <= 32'b0;
            endcase
        end
    end

endmodule