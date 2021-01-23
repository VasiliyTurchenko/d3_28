/* 4 bit to 8 outputs decoder */

module DC8_reg(
	/* A[3] must be zero to enable output of the decocder */
	input wire [3:0] A,
	input wire clk_in,
	input wire res,			// positive
	output reg [7:0] Q,
	output reg [7:0] Qn
);

	reg[7:0] qi;
	
	always @(A) begin
		qi <= 8'b0000_0000;
		case (A)
			4'h0 : qi[0] <= 1'b1;
			4'h1 : qi[1] <= 1'b1;
			4'h2 : qi[2] <= 1'b1;
			4'h3 : qi[3] <= 1'b1;
			4'h4 : qi[4] <= 1'b1;
			4'h5 : qi[5] <= 1'b1;
			4'h6 : qi[6] <= 1'b1;
			4'h7 : qi[7] <= 1'b1;
			default : qi <= 8'b0000_0000;
		endcase
	end

	reg[7:0] Qq;
	reg[7:0] Qqn;
	
	wire nclk;
	assign nclk = ~clk_in;

	always @(negedge clk_in or posedge res or negedge nclk) begin

	if (res || ~nclk ) begin
			Qn <= 8'b1111_1111;
			Q <= 8'b0000_0000;
		end
		else begin
			Qn <= ~qi;
			Q <= qi;
		end
	end

endmodule

/**/
/************** test bench *************************/
`timescale 10ns/1ns
module DC8_reg_test; 

wire [7:0] out;
wire [7:0] outn;

reg [3:0] Addr;
reg clk_in;
reg res;

integer i;

DC8_reg name(.A(Addr), .clk_in(clk_in), .res(res), .Q(out), .Qn(outn));

event dec_ok;
event dec_no;
event dec_res;

/* strobe existing address  */
	initial begin 
		forever begin
		@(dec_ok);
			for (i = 0; i < 8; i = i + 1) begin
					__decode(i, 1);
					#1;
				end
			end
	end

/* strobe non-existing address  */
	initial begin 
		forever begin
		@(dec_no);
			for (i = 8; i < 15; i = i + 1) begin
					__decode(i, 0);
					#1;
			end
		end 
	end

/* strobe under reset   */
	initial begin 
		forever begin
		@(dec_res);
			for (i = 0; i < 15; i = i + 1) begin
					res <= 1'b1;
					__decode(i, 0);
					res <= 1'b0;
					#1;
			end
		end 
	end

/* decode */
	task __decode;
		input [3:0] in_a;
		input expected;

		begin 
			Addr = in_a;
			#1;
			clk_in = 1'b0;
//			#1;

			if ((out == 8'b0000_0000) && ~expected) begin
				// passed
			end
			if ((outn == 8'b1111_1111) && ~expected) begin
				// passed
			end
			
			if ((out == (1'b1 << Addr[2:0])) && ~expected) begin
				$display("Test failed at Addr = %d, expected = %d, actual Q = %d", in_a, expected, out);
				$finish;
			end
			
			if ((outn == ~(1'b1 << Addr[2:0])) && ~expected) begin
				$display("Test failed at Addr = %d, expected = %d, actual Qn = %d", in_a, expected, outn);
				$finish;
			end
			#1;
			clk_in = 1'b1;
			#1;
			if ((outn != 8'b1111_1111) ||(out != 0)) begin
				$display("Tesy failed at line 112");
				$finish;
			end
		end
	endtask

				 
initial 
begin
Addr = 4'b1000;
res = 1'b0;
clk_in = 1'b1;
#512 $finish; 
end 

	initial begin
		forever begin
		#10 -> dec_ok;
		#10000000;
		end		
	end

	initial begin
		forever begin
		#127 -> dec_no;
		#10000000;
		end		
	end

	initial begin
		forever begin
		#255 -> dec_res;
		#10000000;
		end		
	end


endmodule

