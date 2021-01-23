/* Toplevel for the entrie design */

module top(
	input wire ext_clk,		// external xtal generator connection
	input wire ext_reset_n,	// hardware resrt button
	
	output wire [10:1] tn,	// for test purposes
	output reg MHZ_10
);

	/* devboard PS-06 has 50MHz oscillator connected to the pin 23 */
	/* we have to obtain 10MHz clock */
	reg [3:0] div;
	initial div = 4'b0101;
	
	always @(posedge ext_clk) begin
		if (~div) begin
			MHZ_10 <= ~MHZ_10;
			div <= 4'b0101;
		end
		else div <= div - 1;
	end

endmodule

/*  test */
module top_test();
	reg ext_clk;
	wire mhz_10;
	
	top DUT(.ext_clk(ext_clk), .MHZ_10(mhz_10));
	
	initial begin
		ext_clk = 1'b0;
		#200 $finish;
	end
	
	always #1 ext_clk = ~ext_clk;

endmodule
