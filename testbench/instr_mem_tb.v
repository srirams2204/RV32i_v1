`timescale 1ns/1ps

module instr_mem_tb;

  reg [31:0] pc;
  wire [31:0] instr;

  // Instantiate DUT (Device Under Test)
  instr_mem uut (
    .pc(pc),
    .instr(instr)
  );

  initial begin
    $dumpfile("waveform/instr_mem.vcd");   // for GTKWave
    $dumpvars(0, instr_mem_tb);

    // Start at PC = 0
    pc = 0;

    #5;
    $display("PC = %h | Instr = %h", pc, instr);

    // Step through memory
    pc = pc + 4; #5;
    $display("PC = %h | Instr = %h", pc, instr);

    pc = pc + 4; #5;
    $display("PC = %h | Instr = %h", pc, instr);

    pc = pc + 4; #5;
    $display("PC = %h | Instr = %h", pc, instr);

    // Run through first 10 instructions
    repeat (10) begin
      pc = pc + 4; #5;
      $display("PC = %h | Instr = %h", pc, instr);
    end

    $finish;
  end

endmodule
