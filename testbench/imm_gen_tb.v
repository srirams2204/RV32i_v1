`timescale 1ns/1ps

module imm_gen_tb;

    reg [31:0] instr_in;
    wire [31:0] imm_out;

    // Instantiate DUT
    imm_gen uut (
        .imm_out(imm_out),
        .instr_in(instr_in)
    );

    initial begin
        $dumpfile("waveform/imm_gen.vcd");
        $dumpvars(0, imm_gen_tb);
        $display("=== RV32I Immediate Generator Testbench ===");

        // I-type: ADDI x1, x2, 10  -> opcode = 0010011
        instr_in = 32'b000000000101_00010_000_00001_0010011; // imm=5
        #10;
        $display("I-type ADDI imm = %0d (hex %h)", imm_out, imm_out);

        // S-type: SW x1, 8(x2) -> opcode = 0100011
        instr_in = 32'b0000000_00001_00010_010_01000_0100011; // imm=8
        #10;
        $display("S-type SW imm = %0d (hex %h)", imm_out, imm_out);

        // B-type: BEQ x1, x2, -4 -> opcode = 1100011
        instr_in = 32'b1111111_00010_00001_000_11100_1100011; // imm=-4
        #10;
        $display("B-type BEQ imm = %0d (hex %h)", imm_out, imm_out);

        // U-type: LUI x1, 0x12345 -> opcode = 0110111
        instr_in = 32'b00010010001101000101_00001_0110111; // imm=0x12345000
        #10;
        $display("U-type LUI imm = %0d (hex %h)", imm_out, imm_out);

        // J-type: JAL x1, 16 -> opcode = 1101111
        instr_in = 32'b00000000000100000000_00001_1101111; // imm=16
        #10;
        $display("J-type JAL imm = %0d (hex %h)", imm_out, imm_out);

        $display("=== Testbench Finished ===");
        $finish;
    end

endmodule
