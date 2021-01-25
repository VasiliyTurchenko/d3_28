/* RAM */
module ram(
	input wire ram_clk,
	input wire [15:0] Addr_n,
	input wire [3:0] Data,
	input wire [3:0] Z2,
	input wire [3:0] Z3,
	input wire [15:0] _8wn,
	input wire [15:0] _10wn,
	input wire [10:1] tn,
	input [44:1] En,
	output wire [3:0] Y,
	output wire [3:0] X,
	output reg MXn,
	output reg MYn,
	output reg [15:0] VA,		// virtual memory address
	output reg [16:0] MA			// physical memory address
);

	/* local 8w8 .. 8w15 decoder */
	wire [3:0] e17e20;
	reg  [15:8] ram8w;	// positive
	assign e17e20 = {En[17], En[18], En[19], En[20]};
	
	always @(posedge ram_clk) begin
		ram8w <= 8'b000_0000;
		case (e17e20)
			4'd0 : ram8w[15] <= 1;
			4'd1 : ram8w[14] <= 1;
			4'd2 : ram8w[13] <= 1;
			4'd3 : ram8w[12] <= 1;
			4'd4 : ram8w[11] <= 1;
			4'd5 : ram8w[10] <= 1;
			4'd6 : ram8w[9] <= 1;
			4'd7 : ram8w[8] <= 1;
			default: ram8w <= 8'b0000_0000;
		endcase
	end
	
	wire RAM_READ;
	assign RAM_READ = ram8w[8] | ram8w[9] | ram8w[10];
	
	reg UAOZUn;
	wire UAOZU;

	assign UAOZU = ram8w[8] | ram8w[9] | ram8w[10] | ram8w[11] | ram8w[12];
	
	always @(negedge tn[8]) begin
		UAOZUn <= UAOZU;
	end
	
	reg WR;	// common write enable - positive
	always @(posedge tn[10] or negedge tn[3]) begin
		if (~tn[3]) WR <= 0;
		else WR <= ram8w[11] | ram8w[12] | ram8w[13] | ram8w[14];
	end
	
/* nibble selection - negative */	
	always @(posedge tn[10] or negedge tn[5]) begin
		if (~tn[5]) begin
			MXn <= 1'b1;
			MYn <= 1'b1;
		end
		else begin
			MXn <= ~(ram8w[12] | ram8w[14]);
			MYn <= ~(ram8w[11]) | ram8w[13];
		end
	end
	
	/* split pseudo address bus */	
	/* ADDR_n = {A4_n, A3_n, A2_n, A1_n};	*/
	wire [3:0] A1n;
	wire [3:0] A2n;
	wire [3:0] A3n;
	wire [3:0] A4n;
	
	assign A1n = Addr_n[3:0];
	assign A2n = Addr_n[7:4];
	assign A3n = Addr_n[11:8];
	assign A4n = Addr_n[15:12];
	
	/* real RAM address bus */
	wire [1:0] addr_method;
	assign addr_method = {ram8w[10], ram8w[9]};

	always @(negedge UAOZUn) begin
		VA[3:0] <= Z3;
	end

	wire [8:0] amCA3_h;
	assign amCA3_h = {~A3n, ~A4n};
	
	wire [8:0] amCA1_h;
	assign amCA1_h = {~A1n, ~A2n};
	
	wire [8:0] amCCzpC_h;
	assign amCCzpC_h = 8'hff;
	
	always @(negedge UAOZUn) begin
		case (addr_method)
			2'b11 : VA[15:4] <= {amCCzpC_h,  ~En[21], ~En[22], ~En[23], ~En[24]};
			2'b10 : VA[15:4] <= {amCA3_h, Z2};
			2'b01 : VA[15:4] <= {amCA1_h, Z2};
			default : VA[15:4] <= 12'd0;
		endcase
	end

	/* virtual to physical memory translation */
	reg [3:0] page_reg0;
	reg [3:0] page_reg1;	
	reg [3:0] page_reg2;
	reg [3:0] page_reg3;	
	
	always @(negedge tn[4]) begin
			if (ram8w[15] & _10wn[1]) begin
				page_reg0 <= VA[3:0];
				page_reg1 <= VA[7:4];
				page_reg2 <= VA[11:8];
				page_reg3 <= VA[15:12];
			end
	end
	
	always @(posedge ram_clk) begin
		MA[12:0] <= VA[12:0];
		case (VA[14:13])
			2'b00 : MA[16:13] <= page_reg3;
			2'b01 : MA[16:13] <= page_reg2;
			2'b10 : MA[16:13] <= page_reg1;
			2'b11 : MA[16:13] <= page_reg0;
		endcase
	end


ram_low	ram_X (
	.address ( {1'b0, MA[13:0]} ),
	.clock ( ram_clk ),
	.data ( Data ),
	.wren ( WR & ~MXn ),
	.rden(RAM_READ),
	.q ( X )
	);

ram_low	ram_Y (
	.address ( {1'b0, MA[13:0]} ),
	.clock ( ram_clk ),
	.data ( Data ),
	.wren ( WR & ~MYn ),
	.rden(RAM_READ),
	.q ( Y )
	);
	

endmodule
