`include "rv_defs.vh"

module control_unit (
    // Register File
    output reg reg_write,

    // ALU input select
    output reg alu_a_src,      // 0 = rs1, 1 = PC
    output reg alu_b_src,      // 0 = rs2, 1 = imm

    // Data Memory Control
    output reg mem_read,
    output reg mem_write,
    output reg [2:0] mem_funct3,

    // PC Select (2-bit select for your 4x1 mux)
    output reg [1:0] pc_src,

    // Immediate Generator
    output reg [2:0] imm_sel,

    // Writeback MUX
    output reg [1:0] result_src,

    // ALU Control
    output reg [3:0] alu_sel,

    // Instruction fields
    input [2:0] funct3,
    input [6:0] funct7,
    input [6:0] opcode,

    // ALU flags
    input zero,
    input lt_signed,
    input lt_unsigned
);

always @(*) begin

    // ==========================================================
    // DEFAULT VALUES (used if no case matches)
    // ==========================================================
    reg_write   = 0;
    alu_a_src   = 0;
    alu_b_src   = 0;
    mem_read    = 0;
    mem_write   = 0;
    mem_funct3  = funct3;
    pc_src      = 2'b00;
    imm_sel     = `IMM_NONE;
    result_src  = 2'b00;
    alu_sel     = `ADD;


    // ==========================================================
    // OPCODE CASE SELECT
    // ==========================================================
    case (opcode)

    // ==========================================================
    // R–TYPE
    // ==========================================================
    `OPCODE_R_TYPE: begin
        reg_write   = 1;
        alu_a_src   = 0;
        alu_b_src   = 0;
        mem_read    = 0;
        mem_write   = 0;
        mem_funct3  = funct3;
        pc_src      = 2'b00;
        imm_sel     = `IMM_NONE;
        result_src  = 2'b00;

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
            default:          alu_sel = `ADD;
        endcase
    end


    // ==========================================================
    // I–TYPE (ADDI, XORI, ORI, ANDI, shifts)
    // ==========================================================
    `OPCODE_I_TYPE: begin
        reg_write   = 1;
        alu_a_src   = 0;
        alu_b_src   = 1;
        mem_read    = 0;
        mem_write   = 0;
        mem_funct3  = funct3;
        pc_src      = 2'b00;
        imm_sel     = `IMM_I;
        result_src  = 2'b00;

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


    // ==========================================================
    // LOAD (LB, LH, LW, LBU, LHU)
    // ==========================================================
    `OPCODE_LOAD: begin
        reg_write   = 1;
        alu_a_src   = 0;
        alu_b_src   = 1;
        mem_read    = 1;
        mem_write   = 0;
        mem_funct3  = funct3;
        pc_src      = 2'b00;
        imm_sel     = `IMM_I;
        result_src  = 2'b01;
        alu_sel     = `ADD;     // Effective address = rs1 + imm
    end


    // ==========================================================
    // STORE (SB, SH, SW)
    // ==========================================================
    `OPCODE_STORE: begin
        reg_write   = 0;
        alu_a_src   = 0;
        alu_b_src   = 1;
        mem_read    = 0;
        mem_write   = 1;
        mem_funct3  = funct3;
        pc_src      = 2'b00;
        imm_sel     = `IMM_S;
        result_src  = 2'b00;
        alu_sel     = `ADD;
    end


    // ==========================================================
    // BRANCH (BEQ, BNE, BLT, BGE, BLTU, BGEU)
    // ==========================================================
    `OPCODE_BRANCH: begin
        reg_write   = 0;
        alu_a_src   = 0;
        alu_b_src   = 0;
        mem_read    = 0;
        mem_write   = 0;
        mem_funct3  = funct3;
        pc_src      = 2'b00;
        imm_sel     = `IMM_B;
        result_src  = 2'b00;
        alu_sel     = `SUB;

        case (funct3)
            3'b000: if (zero)        pc_src = 2'b01; // BEQ
            3'b001: if (!zero)       pc_src = 2'b01; // BNE
            3'b100: if (lt_signed)   pc_src = 2'b01; // BLT
            3'b101: if (!lt_signed)  pc_src = 2'b01; // BGE
            3'b110: if (lt_unsigned) pc_src = 2'b01; // BLTU
            3'b111: if (!lt_unsigned)pc_src = 2'b01; // BGEU
        endcase
    end


    // ==========================================================
    // JAL — PC = PC + imm, rd = PC+4
    // ==========================================================
    `OPCODE_JAL: begin
        reg_write   = 1;
        alu_a_src   = 0;
        alu_b_src   = 0;
        mem_read    = 0;
        mem_write   = 0;
        mem_funct3  = funct3;
        pc_src      = 2'b01;   // target
        imm_sel     = `IMM_J;
        result_src  = 2'b11;   // PC+4
        alu_sel     = `ADD;
    end


    // ==========================================================
    // JALR — PC = (rs1 + imm) & ~1
    // ==========================================================
    `OPCODE_JALR: begin
        reg_write   = 1;
        alu_a_src   = 0;
        alu_b_src   = 1;
        mem_read    = 0;
        mem_write   = 0;
        mem_funct3  = funct3;
        pc_src      = 2'b10;  // ALU → PC
        imm_sel     = `IMM_I;
        result_src  = 2'b11;
        alu_sel     = `ADD;
    end


    // ==========================================================
    // LUI — rd = imm << 12
    // ==========================================================
    `OPCODE_LUI: begin
        reg_write   = 1;
        alu_a_src   = 0;
        alu_b_src   = 0;
        mem_read    = 0;
        mem_write   = 0;
        mem_funct3  = funct3;
        pc_src      = 2'b00;
        imm_sel     = `IMM_U;
        result_src  = 2'b10;
        alu_sel     = `ADD; // ALU not used
    end


    // ==========================================================
    // AUIPC — rd = PC + (imm << 12)
    // ==========================================================
    `OPCODE_AUIPC: begin
        reg_write   = 1;
        alu_a_src   = 1;   // PC
        alu_b_src   = 1;   // imm
        mem_read    = 0;
        mem_write   = 0;
        mem_funct3  = funct3;
        pc_src      = 2'b00;
        imm_sel     = `IMM_U;
        result_src  = 2'b00;
        alu_sel     = `ADD;
    end

    // ==========================================================
    // DEFAULT CASE
    // ==========================================================
    default: begin
        reg_write   = 0;
        alu_a_src   = 0;
        alu_b_src   = 0;
        mem_read    = 0;
        mem_write   = 0;
        mem_funct3  = funct3;
        pc_src      = 2'b00;
        imm_sel     = `IMM_NONE;
        result_src  = 2'b00;
        alu_sel     = `ADD;
    end

    endcase

end
endmodule
