/* complement calculator *//* full adder */
module fulladder(
	input [3:0] a,  
   input [3:0] b,  
   input c_in,  
   output c_out,  
   output [3:0] sum);  
  
   assign {c_out, sum} = a + b + c_in;  
	
endmodule 


/* BIN or BCD 1-complementer */
module compl(
	input wire [3:0] D_n,	// inverted data
	input wire BCD_ctrl_n,  // 0 - bin, 1-bcd
	output wire [3:0] out);
	
	wire [3:0] a;
	assign a = {~BCD_ctrl_n, 1'b0, 1'b0, ~BCD_ctrl_n};
	
	wire [3:0] s;
	fulladder cmpl(.a(a), .b(D_n), .c_in(~BCD_ctrl_n), .sum(s));
	
	assign out = ~s;

endmodule

`timescale 10ns/1ns
module compl_test;

wire [3:0] out;

reg [3:0] DAT;
reg BCD_ctrl;

compl name(.D_n(~DAT), .BCD_ctrl_n(BCD_ctrl), .out(out));

event BCD_on;

initial begin 
 forever begin
  @(BCD_on);
  BCD_ctrl = 1'b0;
  end 
end

initial 
begin
  DAT = 0;
  BCD_ctrl = 1'b1;

  #16 -> BCD_on;
  #40 $finish; 
end   

always #1 DAT = DAT + 1'b1;

always@(DAT or out or BCD_ctrl) 
$monitor("At time = %t, DAT = %d, BCD_ctrl = %d, Output = %d", $time, DAT, BCD_ctrl, out); 

endmodule

