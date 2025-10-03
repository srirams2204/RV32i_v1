module imm_gen (
    output reg [31:0] imm_out,
    input [31:0] instr_in 
);

wire [6:0] opcode = instr_in[6:0];

always @(*) begin
    case(opcode)
    //I-Type: ADDI, LOAD, JALR
    7'b0010011, 7'b0000011, 7'b1100111: begin
        imm_out = {{20{instr_in[31]}}, instr_in[31:20]};
    end

    //S-Type: STORE
    7'b0100011: begin
        imm_out = {{20{instr_in[31]}}, instr_in[31:25], instr_in[11:7]};
    end

    //B-Type: BRANCH
    7'b1100011: begin
        imm_out = {{19{instr_in[31]}}, instr_in[31], instr_in[7], instr_in[30:25], instr_in[11:8], 1'b0};
    end

    //U-Type: LUI, AUIPC
    7'b0110111, 7'b0010111: begin
        imm_out = {instr_in[31:12], 12'b0};
    end

    //J-Type: JAL
    7'b1101111: begin
        imm_out = {{11{instr_in[31]}}, instr_in[31], instr_in[19:12], instr_in[20], instr_in[30:21], 1'b0};
    end

    default: begin
        imm_out = 32'b0;
    end
    endcase
end
    
endmodule