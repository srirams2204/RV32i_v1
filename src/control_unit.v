module control_unit (
    // -----------------------------------
    // Register File 
    // -----------------------------------
    output reg reg_write,

    // -----------------------------------
    // ALU Input Control
    // -----------------------------------
    output reg alu_a_src,      // 0 = rs1, 1 = PC
    output reg alu_b_src,      // 0 = rs2, 1 = imm

    // -----------------------------------
    // DATA MEMORY Control 
    // -----------------------------------
    output reg mem_read,
    output reg mem_write,
    output reg [1:0] mem_size,
    output reg is_signed,

    // -----------------------------------
    // PC Source Control
    // -----------------------------------
    output reg pc_src,

    // -----------------------------------
    // Immediate Generator Control
    // -----------------------------------
    output reg [2:0] imm_sel,

    // -----------------------------------
    // Writeback MUX Select
    // result_src:
    //   2'b00 = ALU result
    //   2'b01 = Data Memory
    //   2'b10 = Immediate (LUI)
    //   2'b11 = PC+4 (JAL / JALR)
    // -----------------------------------
    output reg [1:0] result_src,

    // -----------------------------------
    // Instruction Fields
    // -----------------------------------
    input [2:0] funct3,
    input [6:0] opcode,

    // -----------------------------------
    // ALU Flags
    // -----------------------------------
    input zero,
    input lt_signed,
    input lt_unsigned
);

always @(*) begin
    // NOTHING HERE — all values must be assigned INSIDE each case
    // You explicitly requested that **every case sets all signals**.
    // This prevents accidental latches and logic conflicts.

    case (opcode)

        // ============================================================
        // R–TYPE
        // ============================================================
        `OPCODE_R_TYPE: begin
            reg_write   = 1;
            alu_a_src   = 0;
            alu_b_src   = 0;
            mem_read    = 0;
            mem_write   = 0;
            mem_size    = 2'b00;
            is_signed   = 0;
            pc_src      = 0;
            imm_sel     = `IMM_NONE;
            result_src  = 2'b00;   // ALU result
        end

        // ============================================================
        // I–TYPE ALU (ADDI/etc)
        // ============================================================
        `OPCODE_I_TYPE: begin
            reg_write   = 1;
            alu_a_src   = 0;
            alu_b_src   = 1;
            mem_read    = 0;
            mem_write   = 0;
            mem_size    = 0;
            is_signed   = 0;
            pc_src      = 0;
            imm_sel     = `IMM_I;
            result_src  = 2'b00;   // ALU result
        end

        // ============================================================
        // LOAD
        // ============================================================
        `OPCODE_LOAD: begin
            reg_write   = 1;
            alu_a_src   = 0;
            alu_b_src   = 1;
            mem_read    = 1;
            mem_write   = 0;
            pc_src      = 0;
            imm_sel     = `IMM_I;
            result_src  = 2'b01;   // Data memory output

            case (funct3)
                3'b000: begin mem_size = 2'b00; is_signed = 1; end // LB
                3'b100: begin mem_size = 2'b00; is_signed = 0; end // LBU
                3'b001: begin mem_size = 2'b01; is_signed = 1; end // LH
                3'b101: begin mem_size = 2'b01; is_signed = 0; end // LHU
                3'b010: begin mem_size = 2'b10; is_signed = 1; end // LW
                default: begin mem_size = 2'b00; is_signed = 0; end
            endcase
        end

        // ============================================================
        // STORE
        // ============================================================
        `OPCODE_STORE: begin
            reg_write   = 0;
            alu_a_src   = 0;
            alu_b_src   = 1;
            mem_read    = 0;
            mem_write   = 1;
            pc_src      = 0;
            imm_sel     = `IMM_S;
            result_src  = 2'b00;   // ALU result (ignored)
            is_signed   = 0;

            case (funct3)
                3'b000: mem_size = 2'b00; // SB
                3'b001: mem_size = 2'b01; // SH
                3'b010: mem_size = 2'b10; // SW
                default: mem_size = 2'b00;
            endcase
        end

        // ============================================================
        // BRANCH
        // ============================================================
        `OPCODE_BRANCH: begin
            reg_write   = 0;
            alu_a_src   = 0;
            alu_b_src   = 0;
            mem_read    = 0;
            mem_write   = 0;
            mem_size    = 0;
            is_signed   = 0;
            imm_sel     = `IMM_B;
            result_src  = 0;

            case (funct3)
                3'b000: pc_src =  (zero);       
                3'b001: pc_src = (!zero);       
                3'b100: pc_src =  (lt_signed);  
                3'b101: pc_src = (!lt_signed);  
                3'b110: pc_src =  (lt_unsigned);
                3'b111: pc_src = (!lt_unsigned);
                default: pc_src = 0;
            endcase
        end

        // ============================================================
        // JAL — rd = PC+4, PC = PC + imm
        // ============================================================
        `OPCODE_JAL: begin
            reg_write   = 1;
            alu_a_src   = 0;
            alu_b_src   = 0;
            mem_read    = 0;
            mem_write   = 0;
            mem_size    = 0;
            is_signed   = 0;
            pc_src      = 1;
            imm_sel     = `IMM_J;
            result_src  = 2'b11;  // PC+4
        end

        // ============================================================
        // JALR
        // ============================================================
        `OPCODE_JALR: begin
            reg_write   = 1;
            alu_a_src   = 0;
            alu_b_src   = 1;
            mem_read    = 0;
            mem_write   = 0;
            pc_src      = 1;
            imm_sel     = `IMM_I;
            result_src  = 2'b11;  // PC+4
            mem_size    = 0;
            is_signed   = 0;
        end

        // ============================================================
        // LUI — rd = imm[31:12] << 12
        // ============================================================
        `OPCODE_LUI: begin
            reg_write   = 1;
            alu_a_src   = 0;
            alu_b_src   = 0; // ALU unused but harmless
            mem_read    = 0;
            mem_write   = 0;
            pc_src      = 0;
            imm_sel     = `IMM_U;
            result_src  = 2'b10;  // immediate goes to rd
            mem_size    = 0;
            is_signed   = 0;
        end

        // ============================================================
        // AUIPC — ALU = PC + imm
        // ============================================================
        `OPCODE_AUIPC: begin
            reg_write   = 1;
            alu_a_src   = 1; // use PC
            alu_b_src   = 1; // imm
            mem_read    = 0;
            mem_write   = 0;
            pc_src      = 0;
            imm_sel     = `IMM_U;
            result_src  = 2'b00;  // ALU result
            mem_size    = 0;
            is_signed   = 0;
        end

        // ============================================================
        // DEFAULT (NOP)
        // ============================================================
        default: begin
            reg_write   = 0;
            alu_a_src   = 0;
            alu_b_src   = 0;
            mem_read    = 0;
            mem_write   = 0;
            mem_size    = 2'b00;
            is_signed   = 0;
            pc_src      = 0;
            imm_sel     = `IMM_NONE;
            result_src  = 2'b00;
        end
    endcase
end

endmodule
