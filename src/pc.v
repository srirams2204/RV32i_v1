module pc(
    output reg [31:0] pc_out,
    input [31:0] pc_in,
    input clk, rst, pc_jmp
);
always @(posedge clk or posedge rst)begin
    if (rst)begin
        pc_out <= 32'h00000000;
    end else if (pc_jmp) begin
        pc_out <= pc_in;
    end else begin
        pc_out <= pc_out + 32'h00000004;
    end
end
endmodule