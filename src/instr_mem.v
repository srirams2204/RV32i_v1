module instr_mem(
    input [31:0] pc,               
    output [31:0] instr
);

reg [31:0] mem [0:15]; // 32 columns, 16 rows of memory (64 bytes total)        

initial begin
    $readmemh("../rv32i_gcc/build/", mem);  // Type the appropriate location of the hex file 
end
assign instr = mem[pc[31:2]];
endmodule