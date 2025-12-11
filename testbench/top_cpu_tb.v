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

// -----------------------------
// PRINT REGISTER FILE EACH CYCLE
// -----------------------------
integer i;

always @(posedge top_clk) begin
    $display("\n================ CYCLE @ %0t ns ================", $time);

    // Print PC
    $display("PC  = %h", uut.pc_addr);

    // Print ALU output
    $display("ALU = %h", uut.alu_out_wire);

    // Print Data Memory output
    $display("DMem Read = %h", uut.mem_out_wire);

    // Print all 32 registers
    $display("Register File:");
    for (i = 0; i < 32; i = i + 1) begin
        $display("x%0d = %h", i, uut.reg_file.register[i]);
    end

    $display("=================================================\n");
end

// -----------------------------
// END SIMULATION AFTER TIMEOUT
// -----------------------------
initial begin
    #2000;   // Sim runs for 2000ns (adjust for program length)
    $display("Simulation finished.");
    $finish;
end

endmodule
