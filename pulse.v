/*  pulse module */
module pulse(
	input wire button_n,
	input wire clk,
	output reg pulse_out
	);
	
	parameter real FREQ = 1000.0;
	parameter real PULSE_US = 1000.0;
	
	parameter unsigned COUNT = PULSE_US * 0.000001 * FREQ;
	reg [32:0] counter;
	reg started;

	initial begin
	  $display("COUNT = %d", COUNT);
	  $display("FREQ = %d", FREQ);
	  $display("PULSE_US = %d", PULSE_US);
	end

	always @(posedge clk) begin
		if ((button_n == 1'b0) && (started == 1'b0)) begin
			$display("started");
			started <= 1'b1;
			counter <= COUNT;
			pulse_out <= 1'b1;
		end
		else if (started == 1'b1) begin
			counter <= counter - 1'b1;
			if (counter == 32'h0) begin
				started <= 1'b0;
				pulse_out <= 1'b0;
			end
		end
		else begin
			pulse_out <= 1'b0;
			started <= 1'b0;
		end
		end	
endmodule

/*****************************************************************/
/*                                                               */
/*                   pulse  test bench 			                 */
/*                                                               */
/*****************************************************************/
`timescale 100ns/100ns
module pulse_test;

	reg clk_in;
	reg button;
	
	wire pulse_out;
	
	pulse #(.FREQ(5000000), .PULSE_US(1000*500)) name (
		.button_n(button),
		.clk(clk_in),
		.pulse_out(pulse_out)
	);
	
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

	initial
	begin
		clk_in = 1'b0;
		button = 1'b1;
		
		#1000 -> push;
		#10 -> rel;

		/* glitches */
		#1000 -> push;
		#2 -> rel;

		
		#10_000_000 $finish;
	end
	
	always #1 clk_in = ~clk_in;

endmodule
