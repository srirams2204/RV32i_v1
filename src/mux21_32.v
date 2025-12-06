module mux21_32 (
    output [31:0] mux_out,
    input [31:0] in0, in1,
    input select
);

assign mux_out = (select) ? in1 : in0;

endmodule