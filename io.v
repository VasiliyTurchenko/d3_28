/* THIS FILE IS THE PART OF D3-28 PROJECT */

module gate(
	input wire A,
	input wire gate,
	output wire C,
	output wire D);
	
	assign C = ~(A & gate);
	assign D = ~(C & gate);
endmodule	

/*****************************************************************/
/*                                                               */
/*               4 bit keyboard reg                              */
/*                                                               */
/*****************************************************************/
module kb_reg(
	input wire [3:0] kbd_in,
	output wire [3:0] kbd_out,
	input wire clk_pos
);
	
	dff_async K1r(.RESET(kbd_in[0]), .SET(1'b1), .DATA(1'b1), .Q(kbd_out[0]), .CLK(clk_pos));
	dff_async K2r(.RESET(kbd_in[1]), .SET(1'b1), .DATA(1'b1), .Q(kbd_out[1]), .CLK(clk_pos));
	dff_async K4r(.RESET(kbd_in[2]), .SET(1'b1), .DATA(1'b1), .Q(kbd_out[2]), .CLK(clk_pos));
   dff_async K8r(.RESET(kbd_in[3]), .SET(1'b1), .DATA(1'b1), .Q(kbd_out[3]), .CLK(clk_pos));

endmodule

/*****************************************************************/
/*                                                               */
/*                keyboard and IO input                          */
/*                                                               */
/*****************************************************************/
module kbd_io(
	input wire key_bit,
	input wire io_bit,
	input wire vv_strobe_n,
	input wire bl,
	input wire sigma_bit,
	input wire clk,
	output wire z_bit
);
	wire mux_out;
	assign mux_out = (key_bit & ~bl) | ( io_bit & bl);
	wire Zreset;
	assign Zreset = ~(mux_out & vv_strobe_n);
	wire Zset;
	assign Zset = ~(Zreset & vv_strobe_n);
	
   dff_async Z4(.RESET(Zreset), .SET(Zset), .DATA(sigma_bit), .Q(z_bit), .CLK(clk));	
endmodule

/* I/O logic */

module io(
	input io_clk,								/* main clock */

	input wire [3:0] sigma_bus, 		/* ALU output data bus */
	input wire [3:0] sigma_bus_n, 	/* ALU output data bus inverted*/
	
	input wire [44:1] En,					/* microcode command bus input */
	
	input wire UAPZU_n,					/* negative */
	input wire [10:1] tn,				/* clock input */
	
	input wire [7:0] _1wn,
	input wire [7:0] _3wn,	
	input wire [15:0] _8wn,
	input wire [15:0] _10wn,
	
	input wire [3:0] Z6,
	
	input wire SIP_Kn,
	input wire SIP_Vn,
	input wire SIPn,
	
	input wire ZL,
	input wire KP,
	input wire NSCH,
	
	input wire RED,
	
	input wire UP1n,
	input wire UP2n,
	
	input wire [3:0] Z0,
	
	input wire init,			// positive pulse
	
	input wire KEY_C,			// negative
	
	input wire [3:0] VVa,					/* periph. input low nibble */
	input wire [3:0] VVb,					/* periph. input high nibble */
	
	/* keyboard connection */
	input wire [3:0] KEYB_A_n,
	input wire [3:0] KEYB_B_n,
	
	/*tape read bit */
	input wire SL_n,
	
	/* step */
	input wire SCH_KEY,							
	
	/* unknown */
	input wire _114,
	
	/* program input */
	input wire V_PR_PUn,
	input wire V_PR_KLn,
	output wire V_PR,
	input wire P_PR,
	output wire P_PRm,
	
	input wire P2,
	input wire P3,
	input wire P4,
	
	/* output data */
	output reg [3:0] Y2n,
	output reg [3:0] X2n,

	/* output address */
	output reg [3:0] Y3n,
	output reg [3:0] X3n,

	output wire BL,
	output wire VV,
	output wire VV_n,
	output wire SIMn,
	output wire LED_PU,
	
	output wire LED_OP,
	output wire OP,

	output wire LED_OM,
	output wire OM,
	
	output wire [3:0] US,
	output wire [3:0] USn,
	output wire USL1n,
	output wire USL2n,
	
	output wire Y3eq12,
	output wire Y3eq13,
	output wire Y3eq14,
	output wire Y3eq15,
	
	output wire GIX,
	output wire GIY,
	
	output wire [3:0] Z4,
	output wire [3:0] Z5,
	output reg step
	
);
	
   /* output data register Y2X2 */
	wire Y2X2_strobe;
	nand(Y2X2_strobe, ~UAPZU_n, ~_8wn[4]);
	
	always @(negedge Y2X2_strobe) begin
		Y2n <= ~Z6;
		X2n <= sigma_bus_n;
	end
	
   /* output I/O address register Y1X1 */
	wire Y3X3_strobe;
	nand(Y3X3_strobe, ~UAPZU_n, ~_8wn[3]);
	
	always @(negedge Y3X3_strobe) begin
		Y3n <= ~Z6;
		X3n <= sigma_bus_n;
	end

	/* BL == 0 means we work with the keyboard */
	assign BL = ~(&Y3n & &X3n);
	
	reg [1:0] SIP_Knr;
	reg [1:0] SIP_Vnr;
	reg [1:0] SIPnr;
	
	always @(posedge io_clk) begin
		SIP_Knr[0] <= SIP_Kn;
		SIP_Knr[1] <= SIP_Knr[0];
		SIP_Vnr[0] <= SIP_Vn;
		SIP_Vnr[1] <= SIP_Vnr[0];
		SIPnr[0] <= SIPn;
		SIPnr[1] <= SIPnr[0];
	end
	
/* synchronous reset */
	reg [1:0] ZLr;
	reg [1:0] KPr;
	reg [1:0] NSCHr;
	reg [1:0] REDr;
	reg [1:0] KEY_Cr;

	always @(posedge io_clk) begin	
		ZLr[0] <= ZL;
		ZLr[1] <= ZLr[0];
		
		KPr[0] <= KP;
		KPr[1] <= KPr[0];
		
		NSCHr[0] <= NSCH;
		NSCHr[1] <= NSCHr[0];
		
		REDr[0] <= RED;
		REDr[1] <= REDr[0];
		
		KEY_Cr[0] <= KEY_C;
		KEY_Cr[1] <= KEY_Cr[0];
		
	end
	
	wire D22A;							// C V I
	and(D22A, ~init, KEY_Cr[1]);
	
	wire D20A;
	nand(D20A, ZLr[1], KPr[1], NSCHr[1], D22A);
	wire D28A;
	nand(D28A, D20A, ~UAPZU_n);
	
	wire C1;
	wire C1n;
	assign C1n = D28A;	
	not(C1, C1n);

/* OP LED and bit */
	wire D30B;
	nand(D30B, En[39], En[40], ~En[38], ~tn[4]);
	wire OP_clear;
	and(OP_clear, D30B, C1n);
	wire OP_set;
	assign OP_set = _10wn[6];
	dff_async OP_trigger(.RESET(OP_clear), .SET(OP_set), .DATA(1'b0), .Q(OP), .Qn(LED_OP), .CLK(1'b0));
	
/* OM LED and bit */	
	wire D21A;
	nand(D21A, ~tn[4], ~_8wn[5], sigma_bus_n[0]);
	wire D21C;
	nand(D21C, ~tn[4], ~_8wn[5], sigma_bus[0]);
	dff_async OM_trigger(.RESET(D21A & C1n), .SET(D21C), .DATA(1'b0), .Q(OM), .Qn(LED_OM), .CLK(1'b0));

/* RED key */	
	wire US8n;
	wire US8;
	gate REDgate(REDr[1], C1, US8n, US8);

/* US4 */	
	wire US4;
	wire US4n;
	gate US4gate(~init, C1, US4n, US4);

/* US2 */	
	wire US2;
	wire US2n;
	nand(US2, ZLr[1], NSCHr[1]);
	nand(US2n, KPr[1], D22A);
	
/* US1 */	
	wire US1;
	wire US1n;
	nand(US1, ZLr[1], KPr[1]);
	nand(US1n, NSCHr[1], D22A);
	
	assign US = {US8, US4, US2, US1};
	assign USn = {US8n, US4n, US2n, US1n};
	
/* VV trigger */	
	wire D18B;
	nand(D18B, SIP_Knr[1], SIP_Vnr[1], SIPnr[1], _8wn[7]);
	
	wire D22D;
	and(D22D, ~UAPZU_n,  D18B);
	
	wire D9B;
	nand(D9B, ~_8wn[1], ~tn[7]);
	
	dff_async VV_trigger(.RESET(D9B), .SET(C1n), .DATA(D18B), .Q(VV), .Qn(VV_n), .CLK(D22D));

/* SIM trigger */	
	wire D21B;
	nand(D21B, BL, ~_8wn[4], ~tn[7]);
	
	dff_async SIM_trigger(.RESET(BL), .SET(D21B), .DATA(1'b0), .Qn(SIMn), .CLK(VV));
	
	nand(LED_PU, VV, BL);

/* D32 decoder */	
	wire [7:0] YX;
	assign YX = {~Y3n, ~X3n};
	reg [3:0] Y3eq;
	always @(posedge io_clk) begin
		case (YX)
			8'hC0 : Y3eq <= 4'b1110;
			8'hD0 : Y3eq <= 4'b1101;
			8'hE0	: Y3eq <= 4'b1011;
			8'hF0	: Y3eq <= 4'b0111;
			default : Y3eq <= 4'b1111;
		endcase
	end
	
	assign Y3eq12 = Y3eq[0];
	assign Y3eq13 = Y3eq[1];
	assign Y3eq14 = Y3eq[2];
	assign Y3eq15 = Y3eq[3];
	
/* USL1, USL2 */	

	reg [1:0] UP1nr;
	reg [1:0] UP2nr;
	
	always @(posedge io_clk) begin
		UP1nr[0] <= UP1n;
		UP1nr[1] <= UP1nr[0];
		UP2nr[0] <= UP2n;
		UP2nr[1] <= UP2nr[0];
	end
		
	wire SIGMA_0;
	assign SIGMA_0 = &sigma_bus_n;

	mux8to1_e USL1_mux(
		.i0(~UP1nr[1]),
		.i1(P3),
		.i2(P4),
		.i3(SIGMA_0),
		.i4(Z0[2]),
		.i5(Z0[0]),
		.i6(1'b1),
		.i7(1'b0),
		.a0(En[43]),
		.a1(En[42]),
		.a2(En[41]),
		.en(1'b0),
		.qn(USL1n));

	mux8to1_e USL2_mux(
		.i0(~UP2nr[1]),
		.i1(VV),
		.i2(P2),
		.i3(OP),
		.i4(Z0[3]),
		.i5(Z0[1]),
		.i6(1'b1),
		.i7(1'b0),
		.a0(En[40]),
		.a1(En[39]),
		.a2(En[38]),
		.en(1'b0),
		.qn(USL2n));

/* NIXIE ctrl */		
	assign GIY = ~BL;
	// TODO !!!! add pulse 
	assign GIX = ~BL & (~OP & ~OM);

/* keyboard and ext. device(s) */	

	wire [3:0] Kb;
	wire [3:0] Ka;

	wire [3:0] KEYB_MA;
	wire [3:0] KEYB_MB;

	xclockd #(.BUS_WIDTH(8)) kbdm(.in({KEYB_B_n, KEYB_A_n}),
											.out({KEYB_MB, KEYB_MA}),
											.clk(io_clk));

	kb_reg KA(.kbd_in(KEYB_MA), .kbd_out(Ka), .clk_pos(VV_n));
	kb_reg KB(.kbd_in(KEYB_MB), .kbd_out(Kb), .clk_pos(VV_n));
	
	wire [3:0] VVAM;
	wire [3:0] VVBM;

	xclockd #(.BUS_WIDTH(8)) vvm(.in({VVb, VVa}),
											.out({VVBM, VVAM}),
											.clk(io_clk));

	kbd_io Z14(.key_bit(Kb[0]), .io_bit(VVBM[0]), .vv_strobe_n(VV_n), .bl(BL),
					.sigma_bit(sigma_bus[0]), .clk(~_3wn[4]), .z_bit(Z4[0]));

	kbd_io Z24(.key_bit(Kb[1]), .io_bit(VVBM[1]), .vv_strobe_n(VV_n), .bl(BL),
					.sigma_bit(sigma_bus[1]), .clk(~_3wn[4]), .z_bit(Z4[1]));
					
	kbd_io Z44(.key_bit(Kb[2]), .io_bit(VVBM[2]), .vv_strobe_n(VV_n), .bl(BL),
					.sigma_bit(sigma_bus[2]), .clk(~_3wn[4]), .z_bit(Z4[2]));

	kbd_io Z84(.key_bit(Kb[3]), .io_bit(VVBM[3]), .vv_strobe_n(VV_n), .bl(BL),
					.sigma_bit(sigma_bus[3]), .clk(~_3wn[4]), .z_bit(Z4[3]));				

	kbd_io Z85(.key_bit(Ka[3]), .io_bit(VVAM[3]), .vv_strobe_n(VV_n), .bl(BL),
					.sigma_bit(sigma_bus[3]), .clk(~_3wn[5]), .z_bit(Z5[3]));

	kbd_io Z45(.key_bit(Ka[2]), .io_bit(VVAM[2]), .vv_strobe_n(VV_n), .bl(BL),
					.sigma_bit(sigma_bus[2]), .clk(~_3wn[5]), .z_bit(Z5[2]));
					
	kbd_io Z25(.key_bit(Ka[1]), .io_bit(VVAM[1]), .vv_strobe_n(VV_n), .bl(BL),
					.sigma_bit(sigma_bus[1]), .clk(~_3wn[5]), .z_bit(Z5[1]));

	/* -8w2.1 */
	wire _8w2_1_n;
	assign _8w2_1_n = ~(~_8wn[2] & ~tn[4]);
	
	/*  Z15 */
	wire [1:0] D46_addr;
	wire VVz15;
	wire BL_n;
	not(BL_n, BL);

	assign D46_addr[0] = (BL_n & _8w2_1_n);
	assign D46_addr[1] = (SL_n & BL_n);
	assign VVz15 = ~(~VV_n & SL_n & _8w2_1_n);
	
	/* metastab _114 */
	wire _114M;
	xclockd #(.BUS_WIDTH(1)) vvmm(.in(_114),
											.out(_114M),
											.clk(io_clk));
	wire D46_pin7;
	assign D46_pin7 = VVAM[0] & (~D46_addr[1] & ~D46_addr[0]) | 
							SL_n &   (~D46_addr[1] & D46_addr[0])  |
							_114M &    (D46_addr[1] & ~D46_addr[0])  |
							Ka[0] &   (D46_addr[1] & D46_addr[0]); 

	wire Z15reset;
	assign Z15reset = ~(D46_pin7 & VVz15);
	wire Z15set;
	assign Z15set = ~(Z15reset & VVz15);
	
   dff_async Z15(.RESET(Z15reset), .SET(Z15set), .DATA(sigma_bus[0]), .Q(Z5[0]), .CLK(~_3wn[5]));		
	/*--------------- Z15 end --------------------------*/

	/* step */
	wire step_keym;
	xclockd #(.BUS_WIDTH(1)) stepm(.in(SCH_KEY),
											.out(step_keym),
											.clk(io_clk));
	
	wire D9B_alu;
	nand(D9B_alu, ~_8wn[6], ~tn[4]);
	wire step_strobe;
	pulse #(.FREQ(10000000), .PULSE_US(100)) step_pulse(
		.button_n(step_keym),
		.clk(alu_clk),
		.pulse_out(step_strobe) );

	always @(posedge step_strobe or negedge D9B_alu) begin
		if (D9B_alu == 1'b0)
			step <= 1'b0;
		else
			step <= 1'b1;
	end
	
	/*   */
	wire V_PR_PUm;
	wire V_PR_KLm;

	xclockd #(.BUS_WIDTH(3)) vprm(.in({V_PR_PUn, V_PR_KLn, P_PR}),
											.out({V_PR_PUm, V_PR_KLm, P_PRm}),
											.clk(io_clk));
	nand(V_PR, V_PR_PUm, V_PR_KLm);
	
	
	
	
endmodule

/*********************************************************************************/
/*                                                                               */
/*						Tests for I/O 																	*/
/*																											*/
/*********************************************************************************/
`timescale 10ns/10ns

module out_test();
	
	reg clk;
	
	wire res_o;
	wire res_o_short;
	
	init	init_impl(
		.clk_in(clk),
		.reset_button_n(1'b1),
		.reset_out(res_o),
		.reset_out_short(res_o_short) );
	
	wire [10:1] tn;
	wire  t_romn;		     // /t pzu
	wire  A_stolb;
	wire	t_RASn;
	

	wire [3:0] US;
	wire [3:0] USn;
	
//xtal_in, init, tn, t_romn, A_stolb, t_RASn
	
	clocks2 clocks_impl(
			.xtal_in(clk),
			.init(res_o_short),
			.tn(tn),
			.t_romn(t_romn),
			.A_stolb(A_stolb),
			.t_RASn(t_RASn));


			
	io DUT(
		.io_clk(clk),
		.init(res_o),
		.US(US),
		.USn(USn),
		.UAPZU_n(t10n),
		.tn(tn),
		.ZL(1'b1),
		.KP(1'b1),
		.NSCH(1'b1),
		.RED(1'b1),
		.KEY_C(1'b1)

	);
	
	initial begin
		clk = 1'b0;
		
		#26_000_000 $finish;
	end
	
	always #5 clk = ~clk;	
	
endmodule

/* keyboard and vv test */
module kbd_io_test();

	reg key_bit;
	reg io_bit;
	reg vv_strobe_n;
	reg bl;
	reg sigma_bit;
	reg clk;
	wire z_bit;

	wire kbd_out;
	dff_async K1r(.RESET(key_bit), .SET(1'b1), .DATA(1'b1), .Q(kbd_out), .CLK(vv_strobe_n));

	kbd_io DUT(kbd_out, io_bit,
		vv_strobe_n, bl,
		sigma_bit, clk,
		z_bit);

	event keyboard_event;
	event input_event;
	event sigma_event;

	task  __keyboard_event;
	begin
		bl = 1'b0;
		#1;
		key_bit = 1'b0;
		#2;
		vv_strobe_n = 1'b0;
		#1;
		vv_strobe_n = 1'b1;
		#1;
		key_bit = 1'b1;	
		#1;
		bl= 1'b1;
		#3;
		bl = 1'b0;
		#1;
		key_bit = 1'b0;
		#2;
		vv_strobe_n = 1'b0;
		#1;
		key_bit = 1'b1;	
		#1;
		vv_strobe_n = 1'b1;
		#1;

	end
	endtask

	initial begin
		forever begin
			@(keyboard_event);
			__keyboard_event();
		end
	end

	initial
	begin
		key_bit = 1'b1;
		io_bit = 1'b1;
		vv_strobe_n = 1'b1;
		bl = 1'b1;
		sigma_bit = 1'b0;
		clk = 1'b0;
		#300 $finish;
	end

	initial begin
		forever begin
		#10 -> keyboard_event;
		#10000000;
		end		
	end


endmodule

