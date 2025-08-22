`timescale 1ns/1ps

module register_tb;

    // Inputs
    reg clk;
    reg rst;
    reg reg_write;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] rd_data;

    // Outputs
    wire [31:0] rs1_data, rs2_data;

    // Instantiate the register file
    register_file uut (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .rd_data(rd_data),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write)
    );

    // Clock generator: 10ns period
    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveform/register_file.vcd");
        $dumpvars(0,register_tb);
        // Initial values
        clk = 0;
        rst = 0;
        reg_write = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        rd_data = 0;

        $display("Starting Register File Testbench");
        $monitor("Time=%0t | rs1=%d rs2=%d rd=%d | rs1_data=%h rs2_data=%h | reg_write=%b rd_data=%h",
                 $time, rs1, rs2, rd, rs1_data, rs2_data, reg_write, rd_data);

        // Apply reset
        #2 rst = 1;
        #10 rst = 0;

        // Try to write to x0 (should not change)
        reg_write = 1;
        rd = 5'd0;
        rd_data = 32'hDEADBEEF;
        #10;

        rs1 = 5'd0; rs2 = 5'd0;
        #2;
        $display("x0 readback (should be 0): rs1_data=%h", rs1_data);

        // Write to register 5
        rd = 5'd5;
        rd_data = 32'hCAFEBABE;
        #10;

        // Read from register 5
        reg_write = 0;
        rs1 = 5'd5;
        rs2 = 5'd0;
        #2;
        $display("Readback from reg[5] (should be CAFEBABE): rs1_data=%h", rs1_data);

        // Write to register 10
        reg_write = 1;
        rd = 5'd10;
        rd_data = 32'h12345678;
        #10;

        // Read from register 10
        reg_write = 0;
        rs1 = 5'd10;
        rs2 = 5'd5;
        #2;
        $display("rs1=reg[10]=%h, rs2=reg[5]=%h", rs1_data, rs2_data);

        // Assert reset again and check cleared registers
        rst = 1;
        #10 rst = 0;
        rs1 = 5'd5;
        rs2 = 5'd10;
        #2;
        $display("After reset again: reg[5]=%h, reg[10]=%h", rs1_data, rs2_data);

        $finish;
    end

endmodule