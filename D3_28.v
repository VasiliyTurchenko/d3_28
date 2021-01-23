/* Toplevel for the entrie design */

module D3_28(
	input wire ext_clk,		// external xtal generator connection
	input wire ext_reset_n,	// hardware resrt button
	
	output wire [10:1] tn,	// for test purposes
	output reg MHZ_10,
	
	/* 7 segment led interface */
	output wire [7:0] pos,
	output wire [7:0] char,
	
	output wire [7:0] io_addr,
	output wire [7:0] io_data,
	output wire SIMn,
	output wire VV,
	
	/* test output */
	output wire test_point
	
);

	/* devboard PS-06 has 50MHz oscillator connected to the pin 23 */
	/* we have to obtain 10MHz clock */
	reg [3:0] div;
	initial div = 4'b0100;
	initial MHZ_10 = 1'b0;
	
	always @(posedge ext_clk) begin
		if (div == 0) begin
			MHZ_10 <= 1'b0;
			div <= 4'b0100;
		end
		else div <= div - 1;
		if (div == 4'b0010) MHZ_10 <= 1'b1;
	end
	
	wire init_master;
	
	machine impl(
						.xtal_clk(MHZ_10),
						.init_ext(ext_reset_n),
						.tn(tn),
						.init_master(init_master),
						
						.SIMn(SIMn),
						.VV(VV),
						.Y3n(io_addr[7:4]),
						.X3n(io_addr[3:0]),

						.Y2n(io_data[7:4]),
						.X2n(io_data[3:0]),
						.test_point(test_point)
						
);		

	/* test for 7 segment led */
	reg [23:0] div_sec;
	initial div_sec = 24'd5_000_000;
	reg one_sec_pulse;
	
	always @ (posedge MHZ_10) begin
		if (div_sec == 24'd0) begin
			one_sec_pulse <= ~one_sec_pulse;
			div_sec <=  24'd5_000_000;
		end
		else 	div_sec <= div_sec - 1'b1;
		end
		
//	assign test_point = one_sec_pulse;

	reg [3:0] outchar;
	reg [2:0] pos_counter;
	wire new_datam;
	
	always @(posedge one_sec_pulse or posedge init_master) begin
		if (init_master) begin
			outchar <= 4'b0000;
			pos_counter <= 3'b000;
		end 
		else if (one_sec_pulse) begin
			outchar <= outchar + 1'b1;
			pos_counter <= pos_counter + 1'b1;
		end
	end

	xclockd #(.BUS_WIDTH(1)) _wrnm(.in(one_sec_pulse),
											 .out(new_datam),
											 .clk(MHZ_10));

	reg new_dataf;
	always @(posedge MHZ_10) begin
		new_dataf <= new_datam;
	end
	
	wire wrn;
	assign wrn = ~(new_datam & ~new_dataf);
	

	led7x8 led7x8__impl(.clk_in(MHZ_10), .init(init_master),
							  .data(outchar), .addr(pos_counter),
							  .seg(char), .pos(pos), .wrn(wrn));

							  
//	assign test_point = io_data[0];
	
endmodule

/*  test */
`timescale 10ns/1ns
module top_test();
	reg ext_clk;
	wire mhz_10;
	
	D3_28 DUT(.ext_clk(ext_clk), .MHZ_10(mhz_10));
	
	initial begin
		ext_clk = 1'b0;
		#200 $finish;
	end
	
	always #1 ext_clk = ~ext_clk;

endmodule
