// BRANCH OFFSET UNIT
module branch_ctrl (
    output [31:0] pc_target,
    input [31:0] pc,
    input [31:0] imm_out
);

assign pc_target = pc + imm_out;

endmodule