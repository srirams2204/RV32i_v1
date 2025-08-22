module instr_mem(
    input [31:0] pc,               
    output [31:0] instr
);

reg [31:0] mem [0:255]; // 32 columns, 256 rows of memory (1kb memory total)        

initial begin
    $readmemh("/home/sriram/Projects/RV32i_v1/rv32i_gcc/output_hex/add.hex", mem);  // location of the hex file 
end
assign instr = mem[pc[31:2]];
endmodule