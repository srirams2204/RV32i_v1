`timescale 1ns/1ps

module tb_data_mem;

reg         clk;
reg         rst;
reg         mem_read;
reg         mem_write;
reg  [1:0]  mem_size;
reg         is_signed;
reg  [31:0] addr;
reg  [31:0] write_data;
wire [31:0] read_data;

// Instantiate DUT
data_mem DUT (
    .read_data(read_data),
    .addr(addr),
    .write_data(write_data),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_size(mem_size),
    .is_signed(is_signed),
    .clk(clk),
    .rst(rst)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;   // 10 ns period
end

// Test procedure
initial begin
    $dumpfile("waveform/dmem_tb.vcd");
    $dumpvars(0, tb_data_mem);
    $display("\n=== DATA MEMORY TESTBENCH START ===\n");

    // Initialize
    rst = 1;
    mem_read  = 0;
    mem_write = 0;
    addr = 0;
    write_data = 0;
    mem_size = 0;
    is_signed = 0;

    #20;
    rst = 0;
    #10;

    // ------------------------------------------------------
    // Test: Store Byte (SB)
    // ------------------------------------------------------
    addr = 10;
    write_data = 32'h000000AA;   // store AA
    mem_size = 2'b00;            // SB
    mem_write = 1;
    #10;
    mem_write = 0;

    // Read back LB (signed)
    mem_read = 1;
    is_signed = 1;
    #10;
    $display("LB (signed) @10 = 0x%h", read_data);
    mem_read = 0;

    // Read back LBU (unsigned)
    mem_read = 1;
    is_signed = 0;
    #10;
    $display("LBU (unsigned) @10 = 0x%h", read_data);
    mem_read = 0;

    // ------------------------------------------------------
    // Test: Store Halfword (SH)
    // ------------------------------------------------------
    addr = 20;
    write_data = 32'h0000BEEF;  // low byte = EF, next = BE
    mem_size = 2'b01;           // SH
    mem_write = 1;
    #10;
    mem_write = 0;

    // LH signed
    mem_read = 1;
    is_signed = 1;
    #10;
    $display("LH (signed) @20 = 0x%h", read_data);
    mem_read = 0;

    // LHU unsigned
    mem_read = 1;
    is_signed = 0;
    #10;
    $display("LHU (unsigned) @20 = 0x%h", read_data);
    mem_read = 0;

    // ------------------------------------------------------
    // Test: Store Word (SW)
    // ------------------------------------------------------
    addr = 100;
    write_data = 32'hDEADBEEF;
    mem_size = 2'b10;         // SW
    mem_write = 1;
    #10;
    mem_write = 0;

    // LW readback
    mem_read = 1;
    #10;
    $display("LW @100 = 0x%h", read_data);
    mem_read = 0;

    // ------------------------------------------------------
    // Test signed byte load producing negative value
    // ------------------------------------------------------
    addr = 10;       // Contains 0xAA = 10101010b = negative if signed
    mem_read = 1;
    is_signed = 1;
    mem_size = 2'b00;
    #10;
    $display("LB signed negative test @10 = 0x%h", read_data);
    mem_read = 0;

    // ------------------------------------------------------
    $display("\n=== TEST COMPLETE ===\n");
    $finish;
end

endmodule
