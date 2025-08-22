`timescale 1ns/1ps

module alu_tb;

    // Testbench signals
    reg  [31:0] A, B;
    reg  [3:0]  sel;
    wire [31:0] alu_out;
    wire zero, lt_signed, lt_unsigned;
    wire negative, carry, overflow;

    // DUT instantiation
    alu dut (
        .A(A),
        .B(B),
        .sel(sel),
        .alu_out(alu_out),
        .zero(zero),
        .lt_signed(lt_signed),
        .lt_unsigned(lt_unsigned),
        .negative(negative),
        .carry(carry),
        .overflow(overflow)
    );

    // Task for displaying results
    task show_result;
        begin
            $display("time=%0t | sel=%b | A=%0d (0x%h) | B=%0d (0x%h) | OUT=%0d (0x%h) | Z=%b N=%b C=%b V=%b | LT_S=%b LT_U=%b",
                     $time, sel, A, A, B, B, alu_out, alu_out,
                     zero, negative, carry, overflow, lt_signed, lt_unsigned);
        end
    endtask

    initial begin
        $dumpfile("waveform/alu.vcd");
        $dumpvars(0, alu_tb);
        $display("===== ALU Testbench Start =====");

        // Test ADD
        A = 32'd10; B = 32'd20; sel = 4'b0000; #10; show_result();
        A = 32'h7FFF_FFFF; B = 32'd1; sel = 4'b0000; #10; show_result(); // overflow test

        // Test SUB
        A = 32'd20; B = 32'd10; sel = 4'b0001; #10; show_result();
        A = 32'h8000_0000; B = 32'd1; sel = 4'b0001; #10; show_result(); // overflow test

        // Test XOR
        A = 32'hF0F0_F0F0; B = 32'h0F0F_0F0F; sel = 4'b0010; #10; show_result();

        // Test OR
        A = 32'h1234_0000; B = 32'h0000_5678; sel = 4'b0011; #10; show_result();

        // Test AND
        A = 32'hFFFF_0000; B = 32'h00FF_00FF; sel = 4'b0100; #10; show_result();

        // Test SLL
        A = 32'h0000_0001; B = 32'd8; sel = 4'b0101; #10; show_result();

        // Test SRL
        A = 32'h8000_0000; B = 32'd4; sel = 4'b0110; #10; show_result();

        // Test SRA
        A = 32'h8000_0000; B = 32'd4; sel = 4'b0111; #10; show_result();

        // Test SLT (signed less than)
        A = -5; B = 10; sel = 4'b1000; #10; show_result();

        // Test SLTU (unsigned less than)
        A = 32'hFFFF_FFFF; B = 32'h0000_0001; sel = 4'b1001; #10; show_result();

        $display("===== ALU Testbench End =====");
        $finish;
    end

endmodule
