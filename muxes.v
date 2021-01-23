/* multiplexers */

/* muxes */
module mux2to1(
	input i0,
	input i1,
	input a0,
	output q);
	
	assign q = (i0 & ~a0) | (i1 & a0);

endmodule

/* 4 to1 mux without enable input */
module mux4to1(
	input i0,
	input i1,
	input i2,
	input i3,
	input a0,
	input a1,
	output q);
	
	wire im0, im1;
	
	mux2to1 mux1(i0, i1, a0, im0);
	mux2to1 mux2(i2, i3, a0, im1);
	mux2to1 mux3(im0, im1, a1, q);

endmodule

/* 4 to1 mux with enable low */
module mux4to1_e(
	input i0,
	input i1,
	input i2,
	input i3,
	input a0,
	input a1,
	input en,
	output q,
	output qn);
	
	wire im0, im1, im2;
	
	mux2to1 mux1(i0, i1, a0, im0);
	mux2to1 mux2(i2, i3, a0, im1);
	mux2to1 mux3(im0, im1, a1, im2);
	mux2to1 ena(im2, 1'b0, en, q);
	not(qn,q);

endmodule

/* 8 to 1 with enable low */
module mux8to1_e(
	input i0,
	input i1,
	input i2,
	input i3,
	input i4,
	input i5,
	input i6,
	input i7,
	input a0,
	input a1,
	input a2,
	input en,
	output q,
	output qn);
	
	wire im0, im1;
	
	mux4to1 mux1(i0, i1, i2, i3, a0, a1, im0);
	mux4to1 mux2(i4, i5, i6, i7, a0, a1, im1);	
	mux4to1 mux3(im0, im1, 1'b0, 1'b0, a2, en, q);
	not(qn, q);

endmodule

module mux16to1(
	input i0,
	input i1,
	input i2,
	input i3,
	input i4,
	input i5,
	input i6,
	input i7,
	input i8,
	input i9,
	input i10,
	input i11,
	input i12,
	input i13,
	input i14,
	input i15,
	
	input a0,
	input a1,
	input a2,
	input a3,
	
	output q);
	
	wire im0, im1, im2, im3;
	
	mux4to1 mux1(i0, i1, i2, i3, a0, a1, im0);
	mux4to1 mux2(i4, i5, i6, i7, a0, a1, im1);	
	mux4to1 mux3(i8, i9, i10, i11, a0, a1, im2);
	mux4to1 mux4(i12, i13, i14, i15, a0, a1, im3);	
	mux4to1 mux5(im0, im1, im2, im3, a2, a3, q);	

endmodule

/***** nibble muxes ************/
module mux2to1_4b(
	input [3:0]i0,
	input [3:0]i1,
	input a0,
	output [3:0]q);

	wire [3:0] aa;
	assign aa = {a0, a0, a0, a0};
	assign q = (i0 & ~aa) | (i1 & aa);	
	
endmodule

/* 4 to1 mux with enable low */
module mux4to1_4b_e(
	input [3:0] i0,
	input [3:0] i1,
	input [3:0] i2,
	input [3:0] i3,
	input a0,
	input a1,
	input en,
	output [3:0] q,
	output [3:0] qn);
	
	wire [3:0] im0;
	wire [3:0] im1;
	wire [3:0] im2;
	
	mux2to1_4b mux1(i0, i1, a0, im0);
	mux2to1_4b mux2(i2, i3, a0, im1);
	mux2to1_4b mux3(im0, im1, a1, im2);
	
	wire [3:0] z;
	assign z = 4'b0000;
	
	mux2to1_4b ena(im2, z, en, q);
	assign qn = ~q;

endmodule

/* 8 to 1 with enable low */
module mux8to1_4b_e(
	input [3:0] i0,
	input [3:0] i1,
	input [3:0] i2,
	input [3:0] i3,
	input [3:0] i4,
	input [3:0] i5,
	input [3:0] i6,
	input [3:0] i7,
	input a0,
	input a1,
	input a2,
	input en,
	output [3:0] q,
	output [3:0] qn);
	
	wire [3:0] im0;
	wire [3:0] im1;
	wire [3:0] z;
	assign z = 4'b0000; 
	
	mux4to1_4b_e mux1(.i0(i0), .i1(i1), .i2(i2), .i3(i3),
			  .a0(a0), .a1(a1), .en(1'b0), .q(im0));
	mux4to1_4b_e mux2(.i0(i4), .i1(i5), .i2(i6), .i3(i7),
			  .a0(a0), .a1(a1), .en(1'b0), .q(im1));	
	mux4to1_4b_e mux3(.i0(im0), .i1(im1), .i2(z), .i3(z),
			  .a0(a2), .a1(1'b0), .en(en), .q(q));
	assign qn = ~q;

endmodule

`timescale 10ns/1ns
module mux_test; 
/*
wire out;
wire outn;
reg [7:0] D;
reg [3:0] A;
reg en;
mux8to1_e name(.i0(D[0]), .i1(D[1]), .i2(D[2]), .i3(D[3]),
             .i4(D[4]), .i5(D[5]), .i6(D[6]), .i7(D[7]),
             .a0(A[0]), .a1(A[1]), .a2(A[2]), .en(en),
            .q(out), .qn(outn)); 
*/

wire [3:0] out;
wire [3:0] outn;

reg [3:0] D0;
reg [3:0] D1;
reg [3:0] D2;
reg [3:0] D3;
reg [3:0] D4;
reg [3:0] D5;
reg [3:0] D6;
reg [3:0] D7;

reg [3:0] A;

reg en;


mux8to1_4b_e name(.i0(D0), .i1(D1), .i2(D2), .i3(D3),
             .i4(D4), .i5(D5), .i6(D6), .i7(D7),
             .a0(A[0]), .a1(A[1]), .a2(A[2]), .en(en),
            .q(out), .qn(outn));
/*
mux4to1_4b_e name(.i0(D0), .i1(D1), .i2(D2), .i3(D3),
             .a0(A[0]), .a1(A[1]), .en(en),
            .q(out), .qn(outn));
*/				
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
D0 = 8'b00000000;
D1 = 8'b00000000;
D2 = 8'b00000000;
D3 = 8'b00000000;
D4 = 8'b00000000;
D5 = 8'b00000000;
D6 = 8'b00000000;
D7 = 8'b00000000;

A = 4'b0000;
en = 1'b1;

#10 -> enable_on;
#150 -> enable_off;

#200 $finish; 
end 

always #1 D0 = D0 + 1'b1;
always #2 D1 = D1 + 1'b1;
always #3 D2 = D2 + 1'b1;
always #4 D3 = D3 + 1'b1;
always #5 D4 = D4 + 1'b1;
always #6 D5 = D5 + 1'b1;
always #7 D6 = D6 + 1'b1;
always #8 D7 = D7 + 1'b1;

always #16 A = A + 1'b1;

always@(D0 or D1 or D2 or D3 or D4 or D5 or D6 or D7 or A) 
$monitor("At time = %t, Output = %d", $time, out); 
endmodule

