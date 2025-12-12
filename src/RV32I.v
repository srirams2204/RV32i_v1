`timescale 1ns / 1ps
`include "pc.v"
`include "mux21_32.v"
`include "PCplus4.v"
`include "instr_mem.v"
`include "imm_gen.v"
`include "branch_ctrl.v"
`include "instr_decoder.v"
`include "register_file.v"
`include "data_mem.v"
`include "control_unit.v"
`include "alu.v"
`include "mux41_32.v"

//==============================================================
// TOP MODULE
//==============================================================
module RV32I(
    input top_clk,
    input top_rst
);

// -------------------------------------------------------------
// PC wires
// -------------------------------------------------------------
wire [31:0] pc_in;
wire [31:0] pc_addr;

// PC MUX inputs
wire [31:0] pc_mux_in0;   // PC + 4
wire [31:0] pc_mux_in1;   // Branch target
wire [31:0] alu_out_wire; // ALU output (for JALR)
wire [1:0]  pc_src;       // NEW 2-bit PC select

// -------------------------------------------------------------
// Instruction memory
// -------------------------------------------------------------
wire [31:0] instr_out;

// -------------------------------------------------------------
// Immediate Generator
// -------------------------------------------------------------
wire [31:0] imm_out;
wire [2:0]  imm_sel;

// -------------------------------------------------------------
// Decoder
// -------------------------------------------------------------
wire [4:0] rs1_wire, rs2_wire, rd_wire;
wire [6:0] opcode_wire;
wire [2:0] funct3_wire;
wire [6:0] funct7_wire;

// -------------------------------------------------------------
// Register File
// -------------------------------------------------------------
wire [31:0] rs1_data_wire;
wire [31:0] rs2_data_wire;
wire [31:0] rd_data_wire;
wire reg_write_wire;

// -------------------------------------------------------------
// ALU wires
// -------------------------------------------------------------
wire [31:0] alu_a;
wire [31:0] alu_b_mux;
wire [3:0]  alu_sel_wire;
wire lt_signed_wire;
wire lt_unsigned_wire;
wire zero_wire;

// -------------------------------------------------------------
// Data Memory
// -------------------------------------------------------------
wire [31:0] mem_out_wire;
wire mem_read_wire;
wire mem_write_wire;
wire [2:0] mem_funct3_wire;

// -------------------------------------------------------------
// Writeback mux select
// -------------------------------------------------------------
wire [1:0] result_src_wire;

// -------------------------------------------------------------
// PC Source MUX (4×1)
// -------------------------------------------------------------
mux41_32 PC_mux(
    .mux_out(pc_in),
    .in0(pc_mux_in0),     // PC + 4
    .in1(pc_mux_in1),     // Branch target
    .in2(alu_out_wire),   // ALU (JALR)
    .in3(32'b0),          // Reserved
    .select(pc_src)
);

// -------------------------------------------------------------
// PC Register
// -------------------------------------------------------------
pc PC_reg(
    .pc_out(pc_addr),
    .pc_nxt(pc_in),
    .clk(top_clk),
    .rst(top_rst)
);

// -------------------------------------------------------------
// Instruction memory
// -------------------------------------------------------------
instr_mem IM(
    .instr(instr_out),
    .pc(pc_addr)
);

// -------------------------------------------------------------
// PC + 4
// -------------------------------------------------------------
PCplus4 PC_incr(
    .pc_plus4(pc_mux_in0),
    .pc_in(pc_addr)
);

// -------------------------------------------------------------
// Immediate generator
// -------------------------------------------------------------
imm_gen Sign_ext(
    .imm_out(imm_out),
    .instr_in(instr_out),
    .imm_sel(imm_sel)
);

// -------------------------------------------------------------
// Branch target = PC + imm
// -------------------------------------------------------------
branch_ctrl branch_control(
    .pc_target(pc_mux_in1),
    .pc(pc_addr),
    .imm_out(imm_out)
);

// -------------------------------------------------------------
// Instruction Decoder
// -------------------------------------------------------------
instr_decoder ID(
    .rs1(rs1_wire),
    .rs2(rs2_wire),
    .rd(rd_wire),
    .opcode(opcode_wire),
    .funct3(funct3_wire),
    .funct7(funct7_wire),
    .instr_in(instr_out)
);

// -------------------------------------------------------------
// Register file
// -------------------------------------------------------------
register_file reg_file(
    .rs1_data(rs1_data_wire),
    .rs2_data(rs2_data_wire),
    .rd_data(rd_data_wire),
    .rs1(rs1_wire),
    .rs2(rs2_wire),
    .rd(rd_wire),
    .reg_write(reg_write_wire),
    .clk(top_clk),
    .rst(top_rst)
);

// -------------------------------------------------------------
// ALU B MUX
// -------------------------------------------------------------
mux21_32 ALU_B_mux(
    .mux_out(alu_b_mux),
    .in0(rs2_data_wire),
    .in1(imm_out),
    .select(alu_b_src)
);

// -------------------------------------------------------------
// ALU A MUX
// -------------------------------------------------------------
mux21_32 ALU_A_mux(
    .mux_out(alu_a),
    .in0(rs1_data_wire),
    .in1(pc_addr),  // AUIPC
    .select(alu_a_src)
);

// -------------------------------------------------------------
// ALU (NOW CONTROLLED DIRECTLY BY CONTROL UNIT)
// -------------------------------------------------------------
alu ALU(
    .alu_out(alu_out_wire),
    .A(alu_a),
    .B(alu_b_mux),
    .sel(alu_sel_wire),     // From updated control_unit
    .zero(zero_wire),
    .lt_signed(lt_signed_wire),
    .lt_unsigned(lt_unsigned_wire)
);

// -------------------------------------------------------------
// UPDATED DATA MEMORY
// -------------------------------------------------------------
data_mem Data_mem(
    .clk(top_clk),
    .rst(top_rst),
    .read_en(mem_read_wire),
    .write_en(mem_write_wire),
    .address(alu_out_wire),
    .write_data(rs2_data_wire),
    .funct3(mem_funct3_wire),
    .read_data(mem_out_wire)
);

// -------------------------------------------------------------
// CONTROL UNIT (NOW INCLUDES ALU CONTROL + PC SRC)
// -------------------------------------------------------------
control_unit CU(
    .reg_write(reg_write_wire),
    .alu_a_src(alu_a_src),
    .alu_b_src(alu_b_src),
    .mem_read(mem_read_wire),
    .mem_write(mem_write_wire),
    .mem_funct3(mem_funct3_wire),
    .pc_src(pc_src),                    // NEW: 2-bit PC control
    .imm_sel(imm_sel),
    .result_src(result_src_wire),
    .alu_sel(alu_sel_wire),             // NEW: ALU select from CU
    .funct3(funct3_wire),
    .funct7(funct7_wire),               // NEW: CU needs funct7 for ALU ops
    .opcode(opcode_wire),
    .zero(zero_wire),
    .lt_signed(lt_signed_wire),
    .lt_unsigned(lt_unsigned_wire)
);

// -------------------------------------------------------------
// WRITEBACK MUX
// -------------------------------------------------------------
mux41_32 WB_mux(
    .mux_out(rd_data_wire),
    .in0(alu_out_wire),
    .in1(mem_out_wire),
    .in2(imm_out),
    .in3(pc_mux_in0),  // PC+4
    .select(result_src_wire)
);

endmodule
