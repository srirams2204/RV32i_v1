`timescale 1ns/1ps

module top_tb;

reg top_clk;
reg top_rst;

// Instantiate CPU
RV32I uut(
    .top_clk(top_clk),
    .top_rst(top_rst)
);

// -----------------------------
// Clock Generation
// -----------------------------
initial begin
    top_clk = 0;
    forever #5 top_clk = ~top_clk;   // 100 MHz clock
end

// -----------------------------
// Reset Generation
// -----------------------------
initial begin
    top_rst = 1;
    #20 top_rst = 0;   // release reset after 20ns
end

// -----------------------------
// Waveform Dump
// -----------------------------
initial begin
    $dumpfile("waveform/top_cpu.vcd");
    $dumpvars(0, top_tb);
end

integer i;

// -----------------------------
// PER-CYCLE PRINT (OPTIONAL)
// -----------------------------
always @(posedge top_clk) begin
    $display("\n================ CYCLE @ %0t ns ================", $time);

    $display("PC  = %h", uut.pc_addr);
    $display("ALU = %h", uut.alu_out_wire);
    $display("DMem Read = %h", uut.mem_out_wire);

    $display("Register File:");
    for (i = 0; i < 32; i = i + 1) begin
        $display("x%0d = %h", i, uut.reg_file.register[i]);
    end

    $display("=================================================\n");
end


// =====================================================
// FINAL REGISTER FILE DUMP (AFTER SIMULATION)
// =====================================================
initial begin
    #2000;  // simulation stop time

    $display("\n================ FINAL REGISTER FILE ================\n");

    for (i = 0; i < 32; i = i + 1) begin
        $display("x%0d = %h", i, uut.reg_file.register[i]);
    end

    $display("\n=====================================================\n");

    $finish;
end


/*
// -----------------------------
// END SIMULATION + DUMP MEMORY
// -----------------------------
initial begin
    #2000;

    $display("\nFINAL REGISTER FILE & MEMORY DUMP:\n");

    uut.Data_mem.dump_memory_bytes();   // <-- WORKS NOW

    $finish;
end
*/

endmodule
