`timescale 1ns/1ps
`include "rv_defs.vh"

module alu (
    output reg [31:0] alu_out,
    input [31:0] A, B,
    input [3:0] sel,

    output zero,
    output lt_signed,
    output lt_unsigned
);

wire [4:0] shamt = B[4:0];

always @(*) begin
    case (sel)
        `ADD:  alu_out = A + B;
        `SUB:  alu_out = A - B;
        `XOR:  alu_out = A ^ B;
        `OR:   alu_out = A | B;
        `AND:  alu_out = A & B;
        `SLL:  alu_out = A << shamt;
        `SRL:  alu_out = A >> shamt;
        `SRA:  alu_out = $signed(A) >>> shamt;
        `SLT:  alu_out = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
        `SLTU: alu_out = (A < B) ? 32'b1 : 32'b0;
        default: alu_out = 32'b0;
    endcase
end

assign zero = (alu_out == 32'b0);
assign lt_signed = ($signed(A) < $signed(B));
assign lt_unsigned = (A < B);

endmodule
