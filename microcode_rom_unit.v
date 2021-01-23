/* microcode ROM unit */

module microcode_rom_unit(
	input	wire t_romn,					/* read registr latch strobe */
	input wire [10:1] tn,
	input	wire [3:0] sigma_bus,		/* ALU output data bus */
	
	input wire [3:0] US,					/* from IO module */
	input wire [3:0] USn, 				/* from IO modile */
	input wire USL1,
	input wire USL2,
	
	output wire [44:1] En);

	reg [5:0]px_bus_n;					/* /PX bus */
	reg [5:0]py_bus_n;					/* /PY bus */
	
	wire [44:1] E;
	wire ROM_readn;					/* address register latch strobe */	
	assign ROM_readn = ~tn[7];
	
	always @(negedge t_romn) begin
		py_bus_n[5] = En[44];
		py_bus_n[4] = En[29];
		py_bus_n[3] = En[30];
		py_bus_n[2] = En[31];
		py_bus_n[1] = En[32];
		py_bus_n[0] = En[33];

		px_bus_n[5] = En[34];
		px_bus_n[4] = En[35];
		
		px_bus_n[3] = En[30];
		px_bus_n[2] = En[31];
		px_bus_n[1] = En[32];
		px_bus_n[0] = En[33];

		
	end
	
	microcode rom(.address({px_bus_n, py_bus_n}),
					 .clock(ROM_readn),
					 .rden(1'b1),
					 .q(E[44:1]));
	
	assign En = ~E;

endmodule

/************** test bench *************************/
`timescale 10ns/1ns
