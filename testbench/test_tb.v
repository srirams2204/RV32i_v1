`timescale 1ns/1ps

module memory_bank_tb;

    reg clk;
    reg rst;
    reg read_en;
    reg write_en;
    reg [31:0] address;
    reg [31:0] write_data;
    reg [2:0] funct3;

    wire [31:0] read_data;

    // Instantiate the DUT
    memory_bank dut (
        .clk(clk),
        .rst(rst),
        .read_en(read_en),
        .write_en(write_en),
        .address(address),
        .write_data(write_data),
        .funct3(funct3),
        .read_data(read_data)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // RESET routine
    initial begin
        rst = 1;
        read_en = 0;
        write_en = 0;
        address = 0;
        write_data = 0;
        funct3 = 0;

        #20 rst = 0;  // Release reset
    end

    // Helper task for readability
    task do_write(input [31:0] addr, input [31:0] data, input [2:0] f3);
    begin
        @(posedge clk);
        write_en = 1;
        read_en = 0;
        address = addr;
        write_data = data;
        funct3 = f3;
        @(posedge clk);
        write_en = 0;
        $display("[WRITE] addr=%h f3=%b data=%h", addr, f3, data);
    end
    endtask

    task do_read(input [31:0] addr, input [2:0] f3);
    begin
        @(posedge clk);
        write_en = 0;
        read_en = 1;
        address = addr;
        funct3 = f3;

        #1; // allow combinational read to settle

        $display("[READ ] addr=%h f3=%b -> data=%h", addr, f3, read_data);

        @(posedge clk);
        read_en = 0;
    end
    endtask

    // Test Sequence
    initial begin
        $dumpfile("waveform/test.vcd");
        $dumpvars(0, memory_bank_tb);
        @(negedge rst);   // wait for reset completion
        $display("\n===== BEGIN MEMORY TEST =====\n");

        // -------------------------------------------------------------
        // 1. Test SW (store word)
        // -------------------------------------------------------------
        do_write(32'h00000004, 32'h11223344, 3'b010);

        // -------------------------------------------------------------
        // 2. Test LW (load word)
        // -------------------------------------------------------------
        do_read(32'h00000004, 3'b010);

        // -------------------------------------------------------------
        // 3. Test SB (store byte)
        // Write 0xAA into byte offset 1
        // -------------------------------------------------------------
        do_write(32'h00000005, 32'h000000AA, 3'b000);

        do_read(32'h00000004, 3'b010); // full word view

        // -------------------------------------------------------------
        // 4. Test SH (store halfword)
        // Store 0xBEEF at offset 2
        // -------------------------------------------------------------
        do_write(32'h00000006, 32'h0000BEEF, 3'b001);

        do_read(32'h00000004, 3'b010);

        // -------------------------------------------------------------
        // 5. Test LB, LBU
        // -------------------------------------------------------------
        do_read(32'h00000005, 3'b000); // LB
        do_read(32'h00000005, 3'b100); // LBU

        // -------------------------------------------------------------
        // 6. Test LH, LHU
        // -------------------------------------------------------------
        do_read(32'h00000004, 3'b001); // LH
        do_read(32'h00000004, 3'b101); // LHU

        // done
        $display("\n===== END MEMORY TEST =====\n");

        $finish;
    end

endmodule
