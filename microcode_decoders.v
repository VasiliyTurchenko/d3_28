/* Microcode decoders */
/* 04-Jan-2020 added test bench for ic74155 */
/* All the micro-instructions are decoded here */


module uCode_dec(
	input wire [44:1] En,							/* microcode command bus input */
	
	/* main clock */
	input wire main_clk,
	
	/* time strobes */
	input wire [10:1]tn,		// negative!
	
	/* output registers active low */
	output wire [7:0]_1wn,
	output wire [7:0]_3wn,
	output wire [15:0]_8wn,
	output wire [15:0]_10wn
);

/* 1w microcommands - set source for alpha adder input */
	wire [3:0] _1w_A;
	assign _1w_A = {En[13] , ~En[1], ~En[2], ~En[3]}; 
	DC8_reg _1wdecoder(.A(_1w_A), .clk_in(tn[5]), .res(1'b0), .Qn(_1wn));
	
/* 2w not decoded */	
	
/* 3w microcommands - set source for beta adder input */	
	wire [3:0] _3w_A;
	assign _3w_A = {1'b0, ~En[7], ~En[8], ~En[9]};
	DC8_reg _3wdecoder(.A(_3w_A), .clk_in(tn[5]), .res(1'b0), .Qn(_3wn));

/* 4w microcommands - set current cycle op for ALU */		

/* 7w is the only E16 */			

/* 8w is the RAM and tape control */
	wire [3:0] _8w_AL;
	wire _8w_AL_ADDR3;
	assign _8w_AL_ADDR3 = ~(En[17] & En[26] & En[25] & En[27] & ~En[28]);
	
	assign _8w_AL = {_8w_AL_ADDR3, ~En[18], ~En[19], ~En[20]};
		
	DC8_reg _8wdecoder_l(.A(_8w_AL), .clk_in(~main_clk), .res(1'b0), .Qn(_8wn[7:0]));
	
	wire [3:0] _8w_AH;
	assign _8w_AH = {En[17], ~En[18], ~En[19], ~En[20]};
	DC8_reg _8wdecoder_h(.A(_8w_AH), .clk_in(~main_clk), .res(1'b0), .Qn(_8wn[15:8]));	
	
/* 10w is the special commands */	
	wire [3:0] _10w_AL_LOW;	// low nibble
	wire [7:0] low_nibble_out;
	assign _10w_AL_LOW = {~En[25], ~En[26], ~En[27], ~En[28]};
	DC8_reg _10wdecoder_ll(.A(_10w_AL_LOW), .clk_in(~main_clk), .res(1'b0), .Qn(low_nibble_out));

	wire [3:0] _10w_AL_HIGH;	// high nibble
	wire [7:0] high_nibble_out;
	assign _10w_AL_HIGH = _10w_AL_LOW;
	DC8_reg _10wdecoder_lh(.A(_10w_AL_HIGH), .clk_in(tn[4]), .res(1'b0), .Qn(high_nibble_out));
	
	assign _10wn[7:0] = {high_nibble_out[3:0], low_nibble_out[3:0]};

	wire [3:0] _10w_AH;	
	assign _10w_AH= {En[25], ~En[26], ~En[27], ~En[28]};
	DC8_reg _10wdecoder_h(.A(_10w_AH), .clk_in(tn[5]), .res(1'b0), .Qn(_10wn[15:8]));		

endmodule
