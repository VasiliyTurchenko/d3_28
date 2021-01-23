/* 7 segment PS-06 display driver */

module led7x8 #(parameter  CLK_FREQ = 10_000_000)(

	input wire clk_in,
	input wire [3:0] data,	// 0...f
	input wire [2:0] addr,
	input wire wrn,			// write to the display by the falling edge
	input wire init,			// positive
	
	output reg [7:0] seg,
	output reg [7:0] pos,
	output reg scan_clk
);

	localparam real T_CYCLE_MS	= 10.0;
	localparam real COUNT = T_CYCLE_MS * 0.001 * CLK_FREQ;
	localparam real DIV = COUNT / 16;

	initial begin
	  $display("CLK_FREQ = %d", CLK_FREQ);
	  $display("T_CYCLE_MS = %d", T_CYCLE_MS);
	  $display("COUNT = %d", COUNT);
	  $display("DIV = %d", DIV);
	end
	
	wire [3:0] datam;
	wire [2:0] addrm;
	wire wrnm;
	
	xclockd #(.BUS_WIDTH(4)) _datam(.in(data),
											.out(datam),
											.clk(clk_in));

	xclockd #(.BUS_WIDTH(3)) _addrm(.in(addr),
											.out(addrm),
											.clk(clk_in));
	
	xclockd #(.BUS_WIDTH(1)) _wrnm(.in(wrn),
											.out(wrnm),
											.clk(clk_in));
	
	reg [4:0] buffer [7:0];
	integer i;
	
	always @(negedge wrnm or posedge init) begin
		if (init) begin 
			// clear mem
			for (i = 0; i < 8; i = i + 1) begin
				buffer[i] <= 5'b10000; // blank position
			end
		end
		else if (~wrnm) begin
			buffer[addrm] <= datam;
		end
	
	end

	// scan counter
//	reg scan_clk;
	reg [19:0] div_cnt;
	initial div_cnt = DIV;
	initial scan_clk = 0;
	
	always @(posedge clk_in) begin
		if (div_cnt == 20'h0) begin
			scan_clk <= ~scan_clk;
			div_cnt <= DIV;
		end
		else begin
			div_cnt <= div_cnt - 1'b1;
		end
	end
	
	reg [4:0] buffer_disp [7:0];
	reg [2:0] cur_pos;
	initial cur_pos = 0;
	
	/* a - bit 0 */
	/* b - bit 1 */
	/* .... */
	/* g - bit 6 */
	/* dp - bit 7 */
	reg [7:0] char_rom [0:16];
	initial begin 
		char_rom[0] = 8'b0011_1111;
		char_rom[1] = 8'b0000_0110;
		char_rom[2] = 8'b0101_1011;
		char_rom[3] = 8'b0100_1111;
		char_rom[4] = 8'b0110_0110;
		char_rom[5] = 8'b0110_1101;		
		char_rom[6] = 8'b0111_1101;		
		char_rom[7] = 8'b0000_0111;
		char_rom[8] = 8'b0111_1111;
		char_rom[9] = 8'b0110_1111;
		char_rom[10] = 8'b0111_0111; // A
		char_rom[11] = 8'b0111_1100; // b
		char_rom[12] = 8'b0011_1001; // C
		char_rom[13] = 8'b0101_1110; // d
		char_rom[14] = 8'b0111_1001; // e
		char_rom[15] = 8'b0111_0001; // f
		char_rom[16] = 8'b0000_0000;  // blank
	end
	
	reg [4:0] code;
	
	always @(posedge scan_clk) begin
		buffer_disp[cur_pos] <= buffer[cur_pos];
		code <= buffer_disp[cur_pos];
		seg <= ~char_rom[code];
		pos <= 8'b1111_1111;
		case (cur_pos)
			4'h0 : pos[6] <= 1'b0;
			4'h1 : pos[7] <= 1'b0;
			4'h2 : pos[0] <= 1'b0;
			4'h3 : pos[1] <= 1'b0;
			4'h4 : pos[2] <= 1'b0;
			4'h5 : pos[3] <= 1'b0;
			4'h6 : pos[4] <= 1'b0;
			4'h7 : pos[5] <= 1'b0;
			default : pos <= 8'b1111_1111;
		endcase

		cur_pos <= cur_pos + 1'b1;		
	end

endmodule


