module ha_tb;
reg a,b;
wire sum,carry;

ha uut(
.sum(sum),
.carry(carry),
.a(a),
.b(b)
);

initial begin
$dumpfile("waveform/ha.vcd");
$dumpvars(0,ha_tb);
a=1'b0;b=1'b0;#10;
a=1'b0;b=1'b1;#10;
a=1'b1;b=1'b0;#10;
a=1'b1;b=1'b1;#10;
end
endmodule