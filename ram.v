/* RAM */
module ram(
	input wire ram_clk,
	input wire [15:0] Addr,
	input wire [3:0] Data,
	input wire [15:0] _8wn,
	input wire [10:1] tn,
	input [44:1] En,
	output wire [3:0] Y,
	output wire [3:0] X,
	output reg MXn,
	output reg MYn
);

	reg RAM_READ;
	
	always @(posedge ram_clk) begin
		RAM_READ <= _8wn[8] & _8wn[9] & _8wn[10];
	end

	wire WR0;
	wire WR1;
	
	wire WR;	// common write enable
	
	assign WR = ((~(~En[18] & ~En[17] & _8wn[15])) & _8wn[11]);

	always @(posedge ram_clk) begin
		if (~tn[5]) begin
			MXn <= 1'b1;
			MYn <= 1'b1;
		end
		else
		if (tn[10]) begin
			MXn <= ~(_8wn[11] & _8wn[13] & _8wn[15] & ~En[17]);
			MYn <= ~(_8wn[12] & _8wn[14] & _8wn[15] & ~En[17]);		
		end
	end
	

ram_low	ram_X (
	.address ( Addr[15:0] ),
	.clock ( ram_clk ),
	.data ( Data ),
	.wren ( tn[4] ),
	.rden(RAM_READ),
	.q ( X )
	);

ram_low	ram_Y (
	.address ( Addr[15:0] ),
	.clock ( ram_clk ),
	.data ( Data ),
	.wren ( tn[4] ),
	.rden(RAM_READ),
	.q ( Y )
	);
	

endmodule
