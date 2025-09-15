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
    $dumpfile("waveform/instr_mem.vcd");   
    $dumpvars(0, instr_mem_tb);
    pc = 0;
    #5;
    $display("PC = %h | Instr = %h", pc, instr);
    pc = pc + 4; #5;
    $display("PC = %h | Instr = %h", pc, instr);
    pc = pc + 4; #5;
    $display("PC = %h | Instr = %h", pc, instr);
    pc = pc + 4; #5;
    $display("PC = %h | Instr = %h", pc, instr);
    repeat (10) begin
      pc = pc + 4; #5;
      $display("PC = %h | Instr = %h", pc, instr);
    end
    $finish;
  end

endmodule
