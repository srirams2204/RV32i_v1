`timescale 1ns/1ps

module pc_tb;

  reg clk;
  reg rst;
  reg pc_jmp;
  reg [31:0] pc_in;
  wire [31:0] pc_out;

  // Instantiate the pc module
  pc uut (
    .pc_out(pc_out),
    .pc_in(pc_in),
    .clk(clk),
    .rst(rst),
    .pc_jmp(pc_jmp)
  );

  // Clock generation: 10ns period
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    // Dump waveform and monitor
    $dumpfile("waveform/pc.vcd");
    $dumpvars(0, pc_tb);

    // Initialize inputs
    rst = 1;
    pc_jmp = 0;
    pc_in = 32'h00000000;

    // Hold reset for 20ns
    #20;
    rst = 0;

    // Wait for a few clock cycles to see increment
    #40;

    // Test jump: load pc_in = 0x1000 and assert pc_jmp
    pc_in = 32'h00001000;
    pc_jmp = 1;
    #10;
    pc_jmp = 0;

    // Wait and see increment from 0x1000
    #40;

    // Test another jump
    pc_in = 32'hFFFFFFFC;
    pc_jmp = 1;
    #10;
    pc_jmp = 0;

    // Wait some cycles
    #40;

    // Finish simulation
    $finish;
  end

endmodule
