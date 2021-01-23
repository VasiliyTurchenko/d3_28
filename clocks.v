/* Clocks for the emulator */
/* XTAL in the original device is 10MHz */

/* 7495 aka 155IR1 */
module ic7495(q0,q1,q2,q3,	// outputs
		cp1,		// right shift
		cp2,		// left shift
		s,		// mode control
		ds,		// serial input
		p0,p1,p2,p3	// parallel inputs
	);

input cp1,cp2,s,ds,p0,p1,p2,p3;
output q0,q1,q2,q3;
wire w3,w4,w5,w6,w7,w8,w9,w10,w11,w12;

not n1(w3,s);
not n2(w7,w3);

and and1(w5,w3,cp1);
and and2(w6,cp2,s);
or or1(w8,w5,w6);

aoi a1(w9,ds,w3,w7,p0);
aoi a2(w10,q0,w3,w7,p1);
aoi a3(w11,q1,w3,w7,p2);
aoi a4(w12,q2,w3,w7,p3);

srff_ ff1(q0,~w9,w9,w8);
srff_ ff2(q1,~w10,w10,w8);
srff_ ff3(q2,~w11,w11,w8);
srff_ ff4(q3,~w12,w12,w8);

endmodule

module aoi(o,a,b,c,d);         //code for module aoi 
input a,b,c,d;
output o;
wire w1,w2;
and(w1,a,b);
and(w2,c,d);
nor(o,w1,w2);
endmodule

//
module srff_(q,s,r,clk);        //code for module srff
input s,r,clk;
output reg q;
always@(negedge clk)
begin
    case({s,r})
    2'b00: q=q; 
    2'b01: q=1'b0;
    2'b10: q=1'b1;
    2'b11: q=1'bx;
    endcase
end
endmodule

/* 7474 aka TM2 */
module SR_latch_gate (input R, input S, output Q, output Qbar);
nand (Q, R, Qbar);
nand (Qbar, S, Q);
endmodule

/********************************/
/* Clock source for the machine */
/********************************/
module clocks(xtal_in, init, t3n, t4n, t5n, t6n, t7n, t8n, t9n, t10n, t10, t_romn, A_stolb);
input xtal_in;
input init;
output  t3n, t4n, t5n, t6n;  // inverted
output  t7n, t8n, t9n, t10n; // inverted
output  t10;
output  t_romn;		     // /t pzu
output  A_stolb;

wire wb;
wire wbn1;
and (wb, t3n, t4n, t5n, t6n, t7n, t8n, t9n, t10n);
not(wbn1, wb);

reg wbn2;
always@(negedge xtal_in) begin
	wbn2 <= wbn1;
end

wire wbn;
assign wbn = wbn1 ? wbn1 : wbn2;

wire cp1;
assign cp1 = xtal_in & ~init;
wire cp2;
assign cp2 = init & xtal_in;
wire s;
assign s = init;


	/*          q0   q1   q2   q3   cp1   cp2   s    ds    p0...*/
	ic7495 d33(t3n, t4n, t5n, t6n, cp1,  cp2,  s, wbn, 1'b1,1'b1,1'b1,1'b1);
	ic7495 d28(t7n, t8n, t9n, t10n, cp1, cp2, s, t6n,  1'b1,1'b1,1'b1,1'b1);

not(t10, t10n);

SR_latch_gate D17BD(.R(t3n), .S(t7n), .Qbar(t_romn) );
SR_latch_gate D16CD(.R(t10n), .S(t5n), .Qbar(A_stolb) );

endmodule

/* Clock source based on states */
module clocks2(xtal_in, init, tn, t_romn, A_stolb, t_RASn, t_CASn, t_RAM_WRn);
	input wire xtal_in;
	input wire init;	// positive logic
	output reg [10:1] tn;	// neg
	output reg t_romn;	// neg
	output reg A_stolb;
	output reg t_RASn;
	output reg t_CASn;
	output reg  t_RAM_WRn;
	parameter init_val = 10'b11_1111_1110;
	initial tn = init_val;
	reg [1:0] helper;
	initial helper = 2'b11;
	always @(posedge xtal_in or posedge init) begin
		if (init) begin
			tn <= 10'b11_1111_1111;
			helper <= 2'b11;
			t_romn <= 1'b1;
			A_stolb <= 1'b0;
			t_RASn <= 1'b1;
			t_CASn <= 1'b1;
			t_RAM_WRn <= 1'b1;
		end
		else begin
			if (helper != 2'b00) helper <= helper - 1'b1;
			if (helper == 2'b10) tn <= init_val;
			else begin
				if (tn == 10'b01_1111_1111) begin
					tn <= init_val;
				end
				else tn <= (tn << 1) | 1'b1;

				if (~tn[9]) A_stolb <= 1'b1;
				if (~tn[4]) A_stolb <= 1'b0;
				
				if (~tn[2]) t_romn <= 1'b0;
				if (~tn[6]) t_romn <= 1'b1;

				if (~tn[8]) t_RASn <= 1'b0;
				if (~tn[4]) t_RASn <= 1'b1;
				
				if (~tn[10]) t_CASn <= 1'b0;
				if (~tn[4]) t_CASn <= 1'b1;

				if (~tn[9]) t_RAM_WRn <= 1'b0;
				if (~tn[2]) t_RAM_WRn <= 1'b1;

			end
		end
	end

	


endmodule



/************** test bench ********************/

`timescale 10ns/1ns
module clocks_test; 

wire [10:1] tn;
wire t_romn;
wire A_stolb;
wire t_RASn;
wire t_CASn;
wire t_RAM_WRn;

reg  clk;
reg  init;

clocks2 name(	.xtal_in(clk),
		.init(init),
		.tn(tn),
		.t_romn(t_romn),
		.A_stolb(A_stolb),
		.t_RASn(t_RASn),
		.t_CASn(t_CASn),
		.t_RAM_WRn(t_RAM_WRn));

initial 
begin
clk = 1'b0;
init = 1'b0;
# 23 init = 1'b1;
# 5 init = 1'b0;
#500 $finish; 
end 

always #1 clk = ~clk;// + 1'b1;

always@(clk or tn or t_romn or A_stolb)
$monitor("At time = %t", $time);
endmodule

module srff_test;

reg s;
reg r;
reg clk;

wire q;

srff_ name(.q(q), .s(s), .r(r), .clk(clk));

event set_on;
event reset_on;
event set_off;
event reset_off;

initial 
begin
clk = 1'b1;
s = 1'b0;
r = 1'b0;
#200 $finish; 
end 

initial begin 
 forever begin
  @(set_on);
  s = 1'b1;
  end 
end


initial begin 
 forever begin
  @(set_off);
  s = 1'b0;
  end 
end

initial begin 
 forever begin
  @(reset_on);
  r = 1'b1;
  end 
end


initial begin 
 forever begin
  @(reset_off);
  r = 1'b0;
  end 
end

always #10 clk = ~clk;// + 1'b1;

initial begin
#21 -> set_on;
#1 -> set_off;

#25 -> set_on;
#49 -> set_off;

#10 -> reset_on;
#2 -> reset_off;

# 5 -> reset_on;
# 25 -> reset_off;

end
endmodule

