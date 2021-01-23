/* root of abstract machine */

module machine(
	input wire xtal_clk,
	
	input wire init_ext,						/* external init button 0 = init, 1 = run */
	
/* external interrupts */	
	input wire EXTI1_n,
	input wire EXTI2_n,
	input wire EXTI4_n,
	input wire EXTI8_n,
	
/* */	
	input wire UP2n,
	input wire UP1n,

/* keyboard connection */
	input wire [3:0] KEYB_A_n,
	input wire [3:0] KEYB_B_n,

/* ext. device input */	
	input wire [3:0] VVa,					/* periph. input low nibble */
	input wire [3:0] VVb,					/* periph. input high nibble */
	
/* ext. device output */
	output wire [3:0] X3n,
	output wire [3:0] Y3n,
	output wire [3:0] X2n,
	output wire [3:0] Y2n,
	
	output wire SIMn,
	output wire VV,
	
	output wire [10:1] tn,
	output wire init_master,
	
	output wire test_point
);

	wire init_clocks;	/* short init pulse */

	/* init logic */
	init init_impl(
		.clk_in(xtal_clk),
		.reset_button_n(init_ext),
		.reset_out(init_master),
		.reset_out_short(init_clocks)) ;


/* clocks wires */
//	wire  [10:1] tn;  // inverted
	wire 	t_romn;		// /t pzu
	wire 	A_stolb;
	wire	t_RASn;
/*
	module clocks(xtal_in, t3n, t4n, t5n, t6n, t7n, t8n, t9n, t10n, t10, t_romn, A_stolb);
*/
	clocks2 clocks2_impl(.xtal_in(xtal_clk),
								.init(init_clocks),
								.tn(tn),
								.t_romn(t_romn),
								.A_stolb(A_stolb),
								.t_RASn(t_Rasn));
							 
	wire [3:0] sigma_bus;	/* ALU output bus */
	wire [3:0] sigma_bus_n;	/* ALU output bus inverted */
	wire [44:1] En;			/* micro-instruction bus */
	wire [15:0] ADDR_n;		/* address bus */

	wire [7:0]_1wn;
	wire [7:0]_3wn;
	wire [15:0]_8wn;
	wire [15:0]_10wn;
	
	wire [3:0] Y_bus;
	wire [3:0] X_bus;
	
	wire [3:0] US;
	wire [3:0] USn;
	
	wire Y3eq12;
	wire Y3eq13;
	wire Y3eq14;
	wire Y3eq15;
 
 
	wire SIP_Kn;
	wire SIP_Vn;
	wire SIPn;

	wire BL;
//	wire VV;
	wire VV_n;
	wire _114;
//	wire SIMn;
	wire LED_PU;
	wire LED_OP;
	wire OP;

	wire LED_OM;
	wire OM;
	
	wire USL1n;
	wire USL2n;
	wire GIX;
	wire GIY;

	
	uCode_dec uCode_dec_impl(.En(En),
									 .main_clk(xtal_clk),
									 .tn(tn),
									 ._1wn(_1wn),
									 ._3wn(_3wn),
									 ._8wn(_8wn),
									 ._10wn(_10wn)
	);
	
	
	 microcode_rom_unit ucode_rom_impl(.t_romn(t_romn),
												 .tn(tn),
												 .rom_uapzu(),
												 .sigma_bus(sigma_bus),
												 .En(En));

	wire P2;
	wire P3;
	wire P4;
	wire [3:0] Z0;
	wire [3:0] Z6;
	
	wire [3:0] Z4;
	wire [3:0] Z5;
	wire SL_n;
	wire step;
	wire V_PR;
	wire P_PRm;
	wire P_PR;
							 
	alu_unit alu_impl(.alu_clk(xtal_clk),
							.alu_sigma_bus(sigma_bus),
							.alu_sigma_bus_n(sigma_bus_n),
							.ADDR_n(ADDR_n),
							.En(En),
							.tn(tn),

							._1wn(_1wn),
							._3wn(_3wn),
							._8wn(_8wn),
							._10wn(_10wn),
	
							.P2(P2),
							.P3(P3),
							.P4(P4),
							.Z0(Z0),
							.Z4(Z4),
							.Z5(Z5),
							.Z6(Z6),
	
							.EXTI1_n(EXTI1_n),
							.EXTI2_n(EXTI2_n),
							.EXTI4_n(EXTI4_n),
							.EXTI8_n(EXTI8_n),
	
							.X_bus(X_bus),
							.Y_bus(Y_bus),
							.step(step),
							.V_PR(V_PR),
							.P_PRm(P_PRm),
							.RAM_READ(tn[4])
	
	);

	ram ram_impl(
							.ram_clk(xtal_clk),
							.Addr(ADDR_n),
							.Data(sigma_bus),
							.Y(Y_bus),
							.X(X_bus),
							._8wn(_8wn),
							.En(En),
							.tn(tn)
	);
	
	io io_impl(
		.io_clk(xtal_clk),
		.sigma_bus(sigma_bus),
		.sigma_bus_n(sigma_bus_n),
	
		.En(En),
	
		.UAPZU_n(t_romn),
		.tn(tn),
	
		._1wn(_1wn),
		._3wn(_3wn),	
		._8wn(_8wn),
		._10wn(_10wn),


		.UP1n(UP1n),
		.UP2n(UP2n),
		
		.KEYB_A_n(KEYB_A_n),
		.KEYB_B_n(KEYB_B_n),
		
		.VVa(VVa),
		.VVb(VVb),
		
	
		.Z0(Z0),
		.Z4(Z4),
		.Z5(Z5),
		.Z6(Z6),		
		
		.P2(P2),
		.P3(P3),
		.P4(P4),

		.SIP_Kn(SIP_Kn),
		.SIP_Vn(SIP_Vn),
		.SIPn(SIPn),
		
		.init(init_master),
		.ZL(1'b1),
		.KP(1'b1),
		.NSCH(1'b1),
		.RED(1'b1),
		
		.KEY_C(1'b1),

		.Y2n(Y2n),
		.X2n(X2n),
		.Y3n(Y3n),
		.X3n(X3n),
	
		.US(US),
		.USn(USn),
	
		.Y3eq12(Y3eq12),
		.Y3eq13(Y3eq13),
		.Y3eq14(Y3eq14),
		.Y3eq15(Y3eq15),
		
		.BL(BL),
		.VV(VV),
		.VV_n(VV_n),
		.SIMn(SIMn),
		.LED_PU(LED_PU),
		.LED_OP(LED_OP),
		.OP(OP),

		.LED_OM(LED_OM),
		.OM(OM),
	
		.USL1n(USL1n),
		.USL2n(USL2n),
		.GIX(GIX),
		.GIY(GIY),

		/*tape read bit */
		.SL_n(SL_n),
	
		/* unknown */
		._114(_114),
		
		.step(step),
		.V_PR(V_PR),
		.P_PR(P_PR),
		.P_PRm(P_PRm)
);
	
	assign test_point = X_bus[1]; 	
endmodule
