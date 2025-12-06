module alu_ctrl (
    output reg [3:0] alu_sel,
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7
);

always @(*) begin
    case (opcode)
        7'b0110011: begin // R-type
            case ({funct7, funct3})
                10'b0000000_000: alu_sel = `ADD;
                10'b0100000_000: alu_sel = `SUB;
                10'b0000000_100: alu_sel = `XOR;
                10'b0000000_110: alu_sel = `OR;
                10'b0000000_111: alu_sel = `AND;
                10'b0000000_001: alu_sel = `SLL;
                10'b0000000_101: alu_sel = `SRL;
                10'b0100000_101: alu_sel = `SRA;
                10'b0000000_010: alu_sel = `SLT;
                10'b0000000_011: alu_sel = `SLTU;
                default:         alu_sel = `ADD;
            endcase
        end

        7'b0010011: begin // I-type arithmetic
            case (funct3)
                3'b000: alu_sel = `ADD;
                3'b100: alu_sel = `XOR;
                3'b110: alu_sel = `OR;
                3'b111: alu_sel = `AND;
                3'b001: alu_sel = `SLL;
                3'b101: alu_sel = (funct7 == 7'b0100000) ? `SRA : `SRL;
                3'b010: alu_sel = `SLT;
                3'b011: alu_sel = `SLTU;
                default: alu_sel = `ADD;
            endcase
        end

        default: alu_sel = `ADD; // safe default
    endcase
end

endmodule