module instr_decoder(
    // Register fields
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    // Operation fields
    output [6:0] opcode,
    output [2:0] funct3,
    output [6:0] funct7,
    // Input instruction
    input [31:0] instr_in
);

// Extract fields directly
assign opcode = instr_in[6:0];
assign rd     = instr_in[11:7];
assign funct3 = instr_in[14:12];
assign rs1    = instr_in[19:15];
assign rs2    = instr_in[24:20];
assign funct7 = instr_in[31:25];

endmodule