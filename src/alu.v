module alu(
    input  [31:0] A,             // rs1
    input  [31:0] B,             // rs2 or imm
    input  [3:0] sel,            // ALU op select
    output reg [31:0] alu_out,   // ALU result

    // Standard RV32I "flags"
    output zero,                 // alu_out == 0
    output lt_signed,            // A < B (signed)
    output lt_unsigned,          // A < B (unsigned)

    // Extra debug flags (not used by RV32I ISA)
    output negative,             // alu_out[31]
    output reg carry,            // carry out from add/sub
    output reg overflow          // signed overflow
);

    wire [4:0] shamt = B[4:0];   // shift amount (low 5 bits)

    // Combinational ALU
    always @(*) begin
        // Default safe values
        alu_out  = 32'd0;
        carry    = 1'b0;
        overflow = 1'b0;

        case (sel)
            4'b0000: begin // ADD
                {carry, alu_out} = {1'b0, A} + {1'b0, B};   // capture carry-out
                overflow = (A[31] == B[31]) && (alu_out[31] != A[31]);
            end
            4'b0001: begin // SUB
                {carry, alu_out} = {1'b0, A} - {1'b0, B};   // carry=borrow detect
                overflow = (A[31] != B[31]) && (alu_out[31] != A[31]);
            end
            4'b0010: alu_out = A ^ B;                       // XOR
            4'b0011: alu_out = A | B;                       // OR
            4'b0100: alu_out = A & B;                       // AND
            4'b0101: alu_out = A << shamt;                  // SLL
            4'b0110: alu_out = A >> shamt;                  // SRL
            4'b0111: alu_out = $signed(A) >>> shamt;        // SRA
            4'b1000: alu_out = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT
            4'b1001: alu_out = (A < B) ? 32'd1 : 32'd0;     // SLTU
            default: alu_out = 32'd0;
        endcase
    end

    // Derived flags
    assign zero        = (alu_out == 32'd0);
    assign negative    = alu_out[31];
    assign lt_signed   = ($signed(A) < $signed(B));
    assign lt_unsigned = (A < B);

endmodule
