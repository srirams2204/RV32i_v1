`timescale 1ns/1ps

module alu_tb;

  reg  [31:0] A, B;
  reg  [3:0]  sel;
  wire [31:0] alu_out;
  wire zero, negative, carry, overflow, lt_signed, lt_unsigned;

  alu dut (
    .A(A),
    .B(B),
    .sel(sel),          
    .alu_out(alu_out),
    .zero(zero),
    .negative(negative),
    .carry(carry),
    .overflow(overflow),
    .lt_signed(lt_signed),
    .lt_unsigned(lt_unsigned)
  );


  task show_result;
    begin
      $display("time=%0t | sel=%b | A=%0d (0x%08x) | B=%0d (0x%08x) | OUT=%0d (0x%08x) | Z=%b N=%b C=%b V=%b | LT_S=%b LT_U=%b",
        $time, sel, A, A, B, B, alu_out, alu_out, zero, negative, carry, overflow, lt_signed, lt_unsigned);
    end
  endtask

  initial begin
    $dumpfile("waveform/alu2.vcd");
    $dumpvars(0, alu_tb);

    $display("===== ALU Testbench Start =====");

    // Existing tests
    #10 sel = 4'b0000; A = 10; B = 20; #10 show_result();   // ADD
    #10 sel = 4'b0000; A = 32'h7fffffff; B = 1; #10 show_result();
    #10 sel = 4'b0001; A = 20; B = 10; #10 show_result();   // SUB
    #10 sel = 4'b0001; A = 32'h80000000; B = 1; #10 show_result();
    #10 sel = 4'b0010; A = 32'hf0f0f0f0; B = 32'h0f0f0f0f; #10 show_result(); // OR
    #10 sel = 4'b0011; A = 32'h12340000; B = 32'h5678; #10 show_result(); // ADD
    #10 sel = 4'b0100; A = 32'hffff0000; B = 32'h00ff00ff; #10 show_result(); // AND
    #10 sel = 4'b0101; A = 32'h1; B = 8; #10 show_result(); // SLL
    #10 sel = 4'b0110; A = 32'h80000000; B = 4; #10 show_result(); // SRL
    #10 sel = 4'b0111; A = 32'h80000000; B = 4; #10 show_result(); // SRA
    #10 sel = 4'b1000; A = -5; B = 10; #10 show_result(); // SLT signed
    #10 sel = 4'b1001; A = 32'hffffffff; B = 1; #10 show_result(); // SLTU

    // ====== NEW edge case tests ======
    #10 sel = 4'b0000; A = 32'hffffffff; B = 1; #10 show_result();  
      // ADD: unsigned carry should be 1, result=0
    #10 sel = 4'b0000; A = 32'h80000000; B = 32'h80000000; #10 show_result();  
      // ADD: signed overflow, carry=1, result=0
    #10 sel = 4'b0001; A = 0; B = 1; #10 show_result();    
      // SUB: borrow occurs, carry flag check
    #10 sel = 4'b0001; A = 32'h7fffffff; B = 32'hffffffff; #10 show_result();  
      // SUB: positive - (-1) = overflow check

    $display("===== ALU Testbench End =====");
    $finish;
  end
endmodule
