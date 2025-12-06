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
`include "alu_ctrl.v"
`include "mux41_32.v"

//TOP MODULE
module RV32I(
    input top_clk,
    input top_rst
);

//PC wire connection
wire [31:0] pc_in;      //PC input
wire [31:0] pc_addr;     //PC output

//PC Mux connection
wire [31:0] pc_mux_in0; //PC mux input 0
wire [31:0] pc_mux_in1; //PC mux input 1
wire pc_src;         //PC mux select

//Instruction Memory wires
wire [31:0] instr_out;

//Sign Extension wire
wire [31:0] imm_out;  //Sign Ext output
wire [2:0] imm_sel;   //Sign Ext select line

//Instr Decoder Wire
wire [4:0] rs1_wire;
wire [4:0] rs2_wire;
wire [4:0] rd_wire;
wire [6:0] opcode_wire;
wire [2:0] funct3_wire;
wire [6:0] funct7_wire;

//Register File wires
wire [31:0] rs1_data_wire;
wire [31:0] rs2_data_wire;
wire [31:0] rd_data_wire;
wire reg_write_wire;

//ALU B Source MUX
wire [31:0] alu_b_mux;

//ALU Wires
wire [31:0] alu_a;
wire [3:0] alu_sel_wire;
wire lt_signed_wire;
wire lt_unsigned_wire;
wire zero_wire;
wire [31:0] alu_out_wire;

//Data memory wires
wire [31:0] mem_out_wire;
wire mem_read_wire;
wire mem_write_wire;
wire [1:0] mem_size_wire;
wire is_signed_wire;

//Control unit wires
wire [1:0] result_src_wire;
wire alu_a_src;
wire alu_b_src;

// ------------------------
// PC Source MUX
// ------------------------
mux21_32 PC_mux(
    .mux_out(pc_in),
    .in0(pc_mux_in0),
    .in1(pc_mux_in1),
    .select(pc_src)
);

// ------------------------
// PC Register
// ------------------------
pc PC_reg(
    .pc_out(pc_addr),
    .pc_nxt(pc_in),
    .clk(top_clk),
    .rst(top_rst)
);

// ------------------------
// Instruction Memory
// ------------------------
instr_mem IM(
    .instr(instr_out),
    .pc(pc_addr)
);

// ------------------------
// Program Incrementer (PC + 4)
// ------------------------
PCplus4 PC_incr(
    .pc_plus4(pc_mux_in0),
    .pc_in(pc_addr)
);

// ------------------------
// Immediate Generator
// ------------------------
imm_gen Sign_ext(
    .imm_out(imm_out),
    .instr_in(instr_out),
    .imm_sel(imm_sel)
);

// ------------------------
// Branch Target (PC + Imm)
// ------------------------
branch_ctrl branch_control(
    .pc_target(pc_mux_in1),
    .pc(pc_addr),
    .imm_out(imm_out)
);

// ------------------------
// Instruction Decoder
// ------------------------
instr_decoder ID(
    .rs1(rs1_wire),
    .rs2(rs2_wire),
    .rd(rd_wire),
    .opcode(opcode_wire),
    .funct3(funct3_wire),
    .funct7(funct7_wire),
    .instr_in(instr_out)
);

// ------------------------
// Register File
// ------------------------
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

// ------------------------
// ALU B input Source MUX
// ------------------------
mux21_32 ALU_B_mux(
    .mux_out(alu_b_mux),
    .in0(rs2_data_wire),
    .in1(imm_out),
    .select(alu_b_src)
);

// ------------------------
// ALU A input Source MUX
// ------------------------
mux21_32 ALU_A_mux(
    .mux_out(alu_a),
    .in0(rs1_data_wire),   // default
    .in1(pc_addr),         // AUIPC uses PC here
    .select(alu_a_src)     // AUIPC instr 
);

// ------------------------
// ALU Module
// ------------------------
alu ALU(
    .alu_out(alu_out_wire),
    .A(alu_a),
    .B(alu_b_mux),
    .sel(alu_sel_wire),
    .zero(zero_wire),
    .lt_signed(lt_signed_wire),
    .lt_unsigned(lt_unsigned_wire)
);

// ------------------------
// ALU Control Unit
// ------------------------
alu_ctrl ALU_control(
    .alu_sel(alu_sel_wire),
    .opcode(opcode_wire),
    .funct3(funct3_wire),
    .funct7(funct7_wire)
);

// ------------------------
// Data Memory
// ------------------------
data_mem Data_mem(
    .read_data(mem_out_wire),
    .addr(alu_out_wire),
    .write_data(rs2_data_wire),
    .mem_read(mem_read_wire),
    .mem_write(mem_write_wire),
    .mem_size(mem_size_wire),
    .is_signed(is_signed_wire),
    .clk(top_clk),
    .rst(top_rst)
);

// ------------------------
// Control Unit
// ------------------------
control_unit CU(
    .reg_write(reg_write_wire),
    .alu_a_src(alu_a_src),
    .alu_b_src(alu_b_src),
    .mem_read(mem_read_wire),
    .mem_write(mem_write_wire),
    .mem_size(mem_size_wire),
    .is_signed(is_signed_wire),
    .pc_src(pc_src),
    .imm_sel(imm_sel),
    .result_src(result_src_wire),
    .funct3(funct3_wire),
    .opcode(opcode_wire),
    .zero(zero_wire),
    .lt_signed(lt_signed_wire),
    .lt_unsigned(lt_unsigned_wire)
);

// ------------------------
// Output Source MUX (ALU/DM) WriteBack 
// ------------------------
mux41_32 WB_mux(
    .mux_out(rd_data_wire),
    .in0(alu_out_wire),
    .in1(mem_out_wire),
    .in2(imm_out),       // for LUI
    .in3(pc_mux_in0), // for JAL/JALR
    .select(result_src_wire)
);

endmodule

//-------------------------------------------------------------------------------------------------------------------
// END OF FILE