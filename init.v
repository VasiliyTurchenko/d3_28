/* initial reset logic */

module init(
	input wire clk_in,
	input wire reset_button_n,
	output wire reset_out,				// positive
	output wire reset_out_short			// positive	
	
);

	reg [15:0] counter;
	reg reset0;
	reg reset1;
	
	always @(posedge clk_in) begin
		reset0 <= reset_button_n;
		reset1 <= reset0;
	end
	
	reg autoreset;
	reg autoreset_short;
	reg [24:0]resetcnt;

	initial resetcnt='h0;
	initial autoreset_short = 1'b1;
	initial autoreset = 1'b1;

	always @ (posedge clk_in) begin
		if (resetcnt != 24'd2_500_000) begin
			resetcnt <= resetcnt + 1'b1;
			autoreset <= 1'b1;
		end
		else begin
			autoreset <= 1'b0;
		end
		
		if (resetcnt > 16'd65535)
			autoreset_short <= 1'b0;
			
		if (reset1 == 1'b0) begin
				resetcnt <= 'h0;
				autoreset <= 1'b1;
				autoreset_short <= 1'b1;
			end
	end

	assign reset_out = ~reset1 | autoreset;
	assign reset_out_short = ~reset1 | autoreset_short;
	
endmodule

/**********************************************************************/
/*                                                                    */
/*          Tests bench                                               */
/*                                                                    */
/**********************************************************************/
`timescale 10ns/10ns
module init_test();

reg clk;
reg button;
wire init_master;
wire init_short;

init DUT(
	.clk_in(clk),
	.reset_button_n(button),
	.reset_out(init_master),
	.reset_out_short(init_short) );

	event push;
	event rel;

	initial begin 
		forever begin
		@(push);
		button = 1'b0;
		end 
	end

	initial begin 
		forever begin
		@(rel);
		button = 1'b1;
		end 
	end

	initial begin
		clk = 1'b0;
		button = 1'b1;
		
		#7000000 -> push;
		#10 -> rel;


		#40000000 -> push;
		#10 -> rel;

		/* glitches */
//		#1000 -> push;
//		#2 -> rel;

		
		#100_000_000 $finish;
	end
	
	always #5 clk = ~clk;

endmodule


