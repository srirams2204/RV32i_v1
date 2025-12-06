// PROGRAM INCREMENTER
module PCplus4 (
    output [31:0] pc_plus4,
    input [31:0] pc_in
);

assign pc_plus4 = pc_in + 4;

endmodule