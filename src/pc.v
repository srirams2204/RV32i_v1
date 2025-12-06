`include "rv_defs.vh"
module pc (
    output reg [31:0] pc_out,
    input [31:0] pc_nxt,
    input clk, rst
);

always @(posedge clk) begin
    if (rst)
        pc_out <= `PC_RESET; // Reset PC to 0
    else
        pc_out <= pc_nxt;       // Update PC with input value
end

endmodule
