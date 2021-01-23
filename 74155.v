/*
		74155
		pin 1 - ea1				pin 16 - +5V
		pin 2 - /ea2				pin 15 - /eb2
		pin 3 - a1				pin 14 - /eb1
		pin 4 - q4				pin 13 - a0
		pin 5 - q3				pin 12 - q8
		pin 6 - q2				pin 11 - q7
		pin 7 - q1				pin 10 - q6
		pin 8 - GND				pin 9  - q5
*/

module ic74155(	/* aka 155ID4 */
	input ea1,
	input ea2,
	input eb1,
	input eb2,
	
	input a0,
	input a1,
	
	output q1,
	output q2,
	output q3,
	output q4,
	output q5,
	output q6,
	output q7,
	output q8
);

	
	wire ena;
	and (ena, ea1, (~ea2));
	wire enb;
	and(enb, (~eb1), (~eb2));
	
	nand(q1, ~a1, ~a0, ena);
	nand(q2, ~a1, a0, ena);
	nand(q3, a1, ~a0, ena);
	nand(q4, a1, a0, ena);
	
	nand(q5, ~a1, ~a0, enb);
	nand(q6, ~a1, a0, enb);
	nand(q7, a1, ~a0, enb);
	nand(q8, a0, a1, enb);


endmodule

/************** test bench *************************/
`timescale 10ns/1ns
module ic74155_test; 

wire [7:0] out;

reg [2:0] inp;

/*
	ea1,
	ea2,
	eb1,
	eb2,
	
	a0,
	a1,
	
	q1, q2, q3, q4,
	q5, q6, q7, q8
*/
reg en;

ic74155 name(.ea1(~inp[2]), .ea2(en), .eb1(~inp[2]), .eb2(en),
		.a0(inp[0]), .a1(inp[1]),
		.q1(out[0]), .q2(out[1]), .q3(out[2]), .q4(out[3]),
		.q5(out[4]), .q6(out[5]), .q7(out[6]), .q8(out[7]));

event enable_on;
event enable_off;

initial begin 
 forever begin
  @(enable_on);
  en = 1'b0;
  end 
end


initial begin 
 forever begin
  @(enable_off);
  en = 1'b1;
  end 
end

				 
initial 
begin
inp = 3'b000;
en = 1'b1;

#8 -> enable_on;
#17 -> enable_off;

#32 $finish; 
end 

always #1 inp = inp + 1'b1;

always@(inp or out) 
$monitor("At time = %t, Input = %d, Output = %d", $time, inp, out); 
endmodule

