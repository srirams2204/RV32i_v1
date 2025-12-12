`timescale 1ns / 1ps

module memory_bank (
    output reg [31:0] read_data, // result of load

    // Control signals
    input read_en,
    input write_en,

    // Address and data
    input [31:0] address,       // byte address
    input [31:0] write_data,    // data for store
    input [2:0]  funct3,        // LOAD/STORE funct3 determines size/sign

    output reg [31:0] read_data, // result of load

    input clk,
    input rst
);

    // 4 KB memory: 1024 x 32-bit words
    reg [31:0] mem [0:255];

    integer i;

    // ------------------------------------------------------------
    // Memory Initialization
    // ------------------------------------------------------------
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'b0;

        // Optional test preload
        mem[0] = 32'hAABBCCDD;
    end

    // ------------------------------------------------------------
    // Decode address
    // ------------------------------------------------------------
    wire [9:0] word_addr = address[31:2];   // select word
    wire [1:0] byte_off  = address[1:0];    // which byte in the word

    // Extract existing bytes from selected word
    wire [7:0] b0 = mem[word_addr][7:0];
    wire [7:0] b1 = mem[word_addr][15:8];
    wire [7:0] b2 = mem[word_addr][23:16];
    wire [7:0] b3 = mem[word_addr][31:24];

    // ------------------------------------------------------------
    // Combinational READ logic (like your original data_mem)
    // Supports LB/LBU/LH/LHU/LW
    // ------------------------------------------------------------
    always @(*) begin
        read_data = 32'b0;

        if (read_en) begin
            case (funct3)

                3'b000: begin // LB
                    case (byte_off)
                        2'b00: read_data = {{24{b0[7]}}, b0};
                        2'b01: read_data = {{24{b1[7]}}, b1};
                        2'b10: read_data = {{24{b2[7]}}, b2};
                        2'b11: read_data = {{24{b3[7]}}, b3};
                    endcase
                end

                3'b100: begin // LBU
                    case (byte_off)
                        2'b00: read_data = {24'b0, b0};
                        2'b01: read_data = {24'b0, b1};
                        2'b10: read_data = {24'b0, b2};
                        2'b11: read_data = {24'b0, b3};
                    endcase
                end

                3'b001: begin // LH
                    if (byte_off == 2'b00)
                        read_data = {{16{b1[7]}}, b1, b0};
                    else if (byte_off == 2'b10)
                        read_data = {{16{b3[7]}}, b3, b2};
                end

                3'b101: begin // LHU
                    if (byte_off == 2'b00)
                        read_data = {16'b0, b1, b0};
                    else if (byte_off == 2'b10)
                        read_data = {16'b0, b3, b2};
                end

                3'b010: begin // LW (must be word-aligned)
                    read_data = {b3, b2, b1, b0};
                end

                default: read_data = 32'b0;
            endcase
        end
    end

    // ------------------------------------------------------------
    // Sequential WRITE logic
    // Uses RV32I SB/SH/SW behavior
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 1024; i = i + 1)
                mem[i] <= 32'b0;
        end

        else if (write_en) begin
            case (funct3)

                // -----------------------------------------
                // SB — store one byte at offset
                // -----------------------------------------
                3'b000: begin
                    case (byte_off)
                        2'b00: mem[word_addr][7:0]   <= write_data[7:0];
                        2'b01: mem[word_addr][15:8]  <= write_data[7:0];
                        2'b10: mem[word_addr][23:16] <= write_data[7:0];
                        2'b11: mem[word_addr][31:24] <= write_data[7:0];
                    endcase
                end

                // -----------------------------------------
                // SH — store half-word
                // Must be either offset 0 or 2
                // -----------------------------------------
                3'b001: begin
                    if (byte_off == 2'b00) begin
                        mem[word_addr][15:0] <= write_data[15:0];
                    end
                    else if (byte_off == 2'b10) begin
                        mem[word_addr][31:16] <= write_data[15:0];
                    end
                end

                // -----------------------------------------
                // SW — store full word
                // -----------------------------------------
                3'b010: begin
                    mem[word_addr] <= write_data;
                end
            endcase
        end
    end

endmodule
