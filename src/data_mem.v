module data_mem(
    output [31:0] read_data,  // 32-bit data read from memory
    input [31:0] addr,         // 32-bit byte address
    input [31:0] write_data,   // 32-bit data to write
    input mem_read,             // Read enable signal
    input mem_write,            // Write enable signal
    input clk,                  // Clock signal
    input rst                   // Reset signal
);

// PARAMETER: Define memory size.
// The memory size is in bytes. A good starting size is 1KB.
parameter MEMORY_SIZE_BYTES = 1024;

// Internal memory array: byte-addressable
reg [7:0] memory [0:MEMORY_SIZE_BYTES-1];

// Internal variable for the for-loop
integer i;

// Combinational Read Logic
// For LW, we need to read 4 bytes starting from the word-aligned address.
// The low bits of the address are ignored for word alignment.
assign read_data = (mem_read) ? {
    memory[{addr[31:2], 2'b0} + 3],
    memory[{addr[31:2], 2'b0} + 2],
    memory[{addr[31:2], 2'b0} + 1],
    memory[{addr[31:2], 2'b0} + 0]
} : 32'b0;

// Sequential Write & Reset Logic
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset logic to clear all memory on reset
        for (i = 0; i < MEMORY_SIZE_BYTES; i = i + 1) begin
            memory[i] <= 8'b0;
        end
    end else if (mem_write) begin
        // For SW, we write 4 bytes to the word-aligned address.
        // Use concatenation for the address to avoid multiplication.
        // Little-endian write: MSB of data to highest address byte, LSB to lowest.
        memory[{addr[31:2], 2'b0} + 3] <= write_data[31:24];
        memory[{addr[31:2], 2'b0} + 2] <= write_data[23:16];
        memory[{addr[31:2], 2'b0} + 1] <= write_data[15:8];
        memory[{addr[31:2], 2'b0} + 0] <= write_data[7:0];
    end
end
endmodule