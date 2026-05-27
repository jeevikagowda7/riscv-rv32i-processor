// ============================================================
// Module : pc_adder
// Description : Computes PC+4 (next sequential instruction).
//               Separate module keeps the design clean.
//               Branch/jump mux will sit above this.
// ============================================================

module pc_adder (
    input  wire [31:0] pc_in,
    output wire [31:0] pc_plus4
);

    assign pc_plus4 = pc_in + 32'd4;

endmodule