module instr_mem(              
    output [31:0] instr,
    input [31:0] pc
);

reg [31:0] mem [0:255]; // 32 columns, 256 rows of memory (1kb memory total)        

initial begin
    $readmemh("/home/sriram/Desktop/u_type.hex", mem);  // location of the hex file 
end
assign instr = mem[pc[31:2]];
endmodule