/* Microcode decoders */
/* 04-Jan-2020 added test bench for ic74155 */
/* All the micro-instructions are decoded here */

/* to comply with the bit order oddity of the D3-28 */
module bit_swapper(
	input wire [7:0] i,
	output wire [7:0] o);
	
	assign o[0] = i[7];
	assign o[1] = i[6];
	assign o[2] = i[5];
	assign o[3] = i[4];
	
	assign o[4] = i[3];
	assign o[5] = i[2];
	assign o[6] = i[1];
	assign o[7] = i[0];

endmodule

module uCode_dec(
	input wire [44:1] En,							/* microcode command bus input */
	
	/* main clock */
	input wire main_clk,
	
	/* time strobes */
	input wire t4n,		// negative!
	input wire t5n,		// negative!
	
	/* output registers active low */
	output wire [7:0]_1wn,

	output reg [7:0]_3wn,
	output reg [7:0]_4wn,

	output reg [15:0]_8wn,

	output reg [15:0]_10wn,
	
	/* output registers active high */
	output reg [7:0]_1w,

	output reg [7:0]_3w,
	output reg [7:0]_4w,

	output reg [15:0]_8w,

	output reg [15:0]_10w	
);

/* 1w microcommands - set source for alpha adder input */
	
/*	wire D6A;
	nand(D6A, ~t5n, En[13]);
	wire [7:0] _1wr;
*/	
	wire [3:0] _1w_A;
	assign _1w_A = {En[13] , ~En[1], ~En[2], ~En[3]}; 
	DC8_reg _1wdec(.A(_1w_A), .clk_in(t5n), .res(1'b0), .Qn(_1wn));
	
/*	
	ic74155 _1wdecoder(.ea1(En[1]), .ea2(D6A),
							 .eb1(D6A), .eb2(En[1]),
							 .a0(En[3]), .a1(En[2]),
							 
							 .q1(_1wr[3]), .q2(_1wr[2]),
							 .q3(_1wr[1]), .q4(_1wr[0]),
							 .q5(_1wr[7]), .q6(_1wr[6]),
							 .q7(_1wr[5]), .q8(_1wr[4]) );
*/
/*
	always @(posedge main_clk) begin
		_1wn = _1wr;
		_1w = ~_1wr;
	end
*/	

/* 2w not decoded */	
	
/* 3w microcommands - set source for beta adder input */	
	wire [7:0] _3wr;
	
	ic74155 _3wdecoder(.ea1(En[7]), .ea2(t5n),
							 .eb1(t5n), .eb2(En[7]),
							 .a0(En[9]), .a1(En[8]),
								 
							 .q5(_3wr[3]), .q6(_3wr[2]),
							 .q7(_3wr[1]), .q8(_3wr[0]),
							 .q1(_3wr[7]), .q2(_3wr[6]),
							 .q3(_3wr[5]), .q4(_3wr[4]) );
								 
	always @(posedge main_clk) begin
		_3wn = _3wr;
		_3w = ~_3wr;
	end

/* 4w microcommands - set current cycle op for ALU */		
	wire [7:0] _4wr;
	
	ic74155 _4wdecoder(.ea1(En[10]), .ea2(1'b0),
							 .eb1(1'b0), .eb2(En[10]),
							 .a0(En[12]), .a1(En[11]),
								 
							 .q5(_4wr[7]), .q6(_4wr[6]),
							 .q7(_4wr[5]), .q8(_4wr[4]),
							 
							 .q1(_4wr[3]), .q2(_4wr[2]),
							 .q3(_4wr[1]), .q4(_4wr[0]) );
								 
	always @(posedge main_clk) begin
		_4wn = _4wr;
		_4w = ~_4wr;
	end

/* 7w is the only E16 */			

/* 8w is the RAM and tape control */

	wire D33C;
	nand(D33C, En[17], _10wr[1]);
	
	wire [15:0] _8wr;
	ic74155 _8wdecoder_l(.ea1(En[18]), .ea2(D33C),
							 .eb1(D33C), .eb2(En[18]),
							 .a0(En[20]), .a1(En[19]),
								 
							 .q1(_8wr[3]), .q2(_8wr[2]),
							 .q3(_8wr[1]), .q4(_8wr[0]),
							 .q5(_8wr[7]), .q6(_8wr[6]),
							 .q7(_8wr[5]), .q8(_8wr[4])  );
	
	ic74155 _8wdecoder_h(.ea1(En[18]), .ea2(En[17]),
							 .eb1(En[17]), .eb2(En[18]),
							 .a0(En[20]), .a1(En[19]),
								 
							 .q1(_8wr[11]), .q2(_8wr[10]),
							 .q3(_8wr[9]), .q4(_8wr[8]),
							 .q5(_8wr[15]), .q6(_8wr[14]),
							 .q7(_8wr[13]), .q8(_8wr[12])  );
	
	
	
	always @(posedge main_clk) begin
		_8wn = _8wr;
		_8w = ~_8wr;
	end

	
	
	
	
	
	
	
	
/* 10w is the special commands */	
	
	wire [15:0] _10wr;
	wire D1B;
	nand(D1B, ~t4n, En[25]);
	
	ic74155 _10w0_decoder(.ea1(En[26]), .ea2(~En[25]),
								 .eb1(D1B), .eb2(En[26]),
								 .a0(En[28]), .a1(En[27]),
								 
								 .q1(_10wr[3]), .q2(_10wr[2]),
								 .q3(_10wr[1]), .q4(_10wr[0]),
								 .q5(_10wr[7]), .q6(_10wr[6]),
								 .q7(_10wr[5]), .q8(_10wr[4]) );

	wire D1C;
	nand(D1C, ~En[25], ~t5n);
	
	ic74155 _10w8_decoder(.ea1(En[26]), .ea2(D1C),
								 .eb1(D1C), .eb2(En[26]),
								 .a0(En[28]), .a1(En[27]),
								 
								 .q1(_10wr[11]), .q2(_10wr[10]),
								 .q3(_10wr[9]), .q4(_10wr[8]),
								 .q5(_10wr[15]), .q6(_10wr[14]),
								 .q7(_10wr[13]), .q8(_10wr[12]) );

	always @(posedge main_clk) begin
		_10wn = _10wr;
		_10w = ~_10wr;
	end
								 

endmodule
