// ============================================================
// Module : data_mem (Data Memory)
// Project : RV32I Pipelined Processor
// Description : Synchronous write, asynchronous read.
//               Supports byte, halfword, word access.
//               1KB byte-addressable data memory.
// ============================================================

module data_mem (
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [1:0]  mem_size,
    input  wire        mem_signed,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output reg  [31:0] read_data
);

    reg [7:0] mem [0:1023];

    // Synchronous write
    always @(posedge clk) begin
        if (mem_write) begin
            case (mem_size)
                2'b10: begin
                    mem[addr]   <= write_data[7:0];
                    mem[addr+1] <= write_data[15:8];
                    mem[addr+2] <= write_data[23:16];
                    mem[addr+3] <= write_data[31:24];
                end
                2'b01: begin
                    mem[addr]   <= write_data[7:0];
                    mem[addr+1] <= write_data[15:8];
                end
                2'b00:
                    mem[addr]   <= write_data[7:0];
            endcase
        end
    end

    // Asynchronous read
    always @(*) begin
        if (mem_read) begin
            case (mem_size)
                2'b10:
                    read_data = {mem[addr+3], mem[addr+2],
                                 mem[addr+1], mem[addr]};
                2'b01:
                    read_data = mem_signed ?
                        {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]} :
                        {16'b0,                mem[addr+1], mem[addr]};
                2'b00:
                    read_data = mem_signed ?
                        {{24{mem[addr][7]}}, mem[addr]} :
                        {24'b0,              mem[addr]};
                default: read_data = 32'b0;
            endcase
        end else begin
            read_data = 32'b0;
        end
    end

endmodule