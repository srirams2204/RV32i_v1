// REGISTER FILE
module register_file(
    output [31:0] rs1_data, rs2_data,
    input [31:0] rd_data,
    input [4:0] rs1, rs2, rd,
    input clk, rst, reg_write
);

// 32 general-purpose 32-bit registers
reg [31:0] register [0:31];

// Read logic (combinational)
assign rs1_data = (rs1 == 5'd0) ? 32'b0 : register[rs1];
assign rs2_data = (rs2 == 5'd0) ? 32'b0 : register[rs2];

// Write and reset logic (synchronous)
integer i;
always @(posedge clk) begin
    if (rst) begin
        for (i = 0; i < 32; i = i + 1)
            register[i] <= 32'b0;
    end 
    else if (reg_write && (rd != 5'd0)) begin
        register[rd] <= rd_data;
    end
end

endmodule
