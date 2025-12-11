module data_mem(
    output reg [31:0] read_data,
    input  [31:0] addr,
    input  [31:0] write_data,
    input         mem_read,
    input         mem_write,
    input  [1:0]  mem_size,
    input         is_signed,
    input         clk,
    input         rst
);

parameter MEMORY_SIZE_BYTES = 1024;

reg [7:0] memory [0:MEMORY_SIZE_BYTES-1];

reg [7:0]  byte_data;
reg [15:0] half_word;

integer i;

// ============================================================================
// Synchronous WRITE logic
// ============================================================================
always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < MEMORY_SIZE_BYTES; i = i + 1)
            memory[i] <= 8'b0;
    end 
    else if (mem_write) begin
        case (mem_size)
            2'b00: begin // SB
                memory[addr] <= write_data[7:0];
            end 

            2'b01: begin // SH
                memory[addr]     <= write_data[7:0];
                memory[addr + 1] <= write_data[15:8];
            end 

            2'b10: begin // SW
                memory[addr]     <= write_data[7:0];
                memory[addr + 1] <= write_data[15:8];
                memory[addr + 2] <= write_data[23:16];
                memory[addr + 3] <= write_data[31:24];
            end
        endcase
    end
end

// ============================================================================
// Combinational READ logic
// ============================================================================
always @(*) begin
    // default value
    read_data = 32'b0;

    if (mem_read) begin
        case (mem_size)
            // -------------------------------------------------
            // BYTE LOAD
            // -------------------------------------------------
            2'b00: begin
                byte_data = memory[addr];

                if (is_signed)
                    read_data = {{24{byte_data[7]}}, byte_data};
                else
                    read_data = {24'b0, byte_data};
            end

            // -------------------------------------------------
            // HALFWORD LOAD
            // -------------------------------------------------
            2'b01: begin
                half_word = {memory[addr+1], memory[addr]};

                if (is_signed)
                    read_data = {{16{half_word[15]}}, half_word};
                else
                    read_data = {16'b0, half_word};
            end

            // -------------------------------------------------
            // WORD LOAD
            // -------------------------------------------------
            2'b10: begin
                read_data = {
                    memory[addr + 3],
                    memory[addr + 2],
                    memory[addr + 1],
                    memory[addr]
                };
            end
        endcase
    end
end

endmodule
