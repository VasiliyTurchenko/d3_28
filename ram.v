//                 -*- Mode: Verilog -*-
// Filename        : ram.v
// Description     : RAM subsystem for D3-28
  
module ram(
	   input wire 	     ram_clk,
	   input wire [15:0] Addr_n,
	   input wire [3:0]  Data,
	   input wire [3:0]  Z2,
	   input wire [3:0]  Z3,
	   input wire [15:0] _10wn,
	   input wire [10:1] tn,
	   input [44:1]      En,
	   output reg [3:0]  Y,
	   output reg [3:0]  X,
	   output reg 	     MXn,
	   output reg 	     MYn,
	   output reg [15:0] VA, /* virtual memory address */
	   output reg [16:0] MA	 /* physical memory address */
	   );

   /* local 8w8 .. 8w15 decoder */
   wire [3:0] 		     e17e20;
   reg [15:8] 		     ram8w;	// positive
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
   
   reg 	UAOZUn;
   wire UAOZU;
   
   assign UAOZU = ram8w[8] | ram8w[9] | ram8w[10] | ram8w[11] | ram8w[12];
   
   wire u0;
   assign u0 = (~tn[8]) ? ~UAOZU : 1;
   always @(negedge ram_clk) begin
      UAOZUn <= u0;
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
		   MYn <= ~(ram8w[11] | ram8w[13]);
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
      if (ram8w[15] & ~_10wn[1]) begin
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
   
   wire [3:0] Xr;
   wire       wrenX;
   assign wrenX = WR & ~MXn;
   ram_low	ram_X (
		       .address ( {1'b0, MA[13:0]} ),
		       .clock ( ram_clk ),
		       .data ( Data ),
		       .wren ( wrenX ),
		       .rden(RAM_READ),
		       .q ( Xr ) );
   
   wire [3:0] Yr;
   wire       wrenY;
   assign wrenY =  WR & ~MYn;
   ram_low	ram_Y (
		       .address ( {1'b0, MA[13:0]} ),
		       .clock ( ram_clk ),
		       .data ( Data ),
		       .wren ( wrenY ),
		       .rden(RAM_READ),
		       .q ( Yr ) );

   always @(posedge tn[4]) begin
      X <= Xr;
      Y <= Yr;
   end
   
endmodule

/*********************************************************************************/
/*                                                                               */
/*                    Testbench                                                  */
/*                                                                               */
/*********************************************************************************/
`timescale 10ns/10ns

module ram_test();
   /* En operation encoding  -E20 -E19 -E18 -E17 */
   parameter ram_operation_CC 	= 4'b1110;    /* 8w8 */
   parameter ram_operation_CA1 	= 4'b0110;    /* 8w9 */
   parameter ram_operation_CA3 	= 4'b1010;    /* 8w10 */
   parameter ram_operation_ZPCY	= 4'b0010;    /* 8w11 address is set as in the case of CC */
   parameter ram_operation_ZPCX	= 4'b1100;    /* 8w12 address is set as in the case of CC */
   parameter ram_operation_ZPY 	= 4'b0100;    /* 8w13 no address reg change */
   parameter ram_operation_ZPX 	= 4'b1000;    /* 8w14 no address reg change */
   parameter ram_operation_wr_ppage_reg = 4'd0; /* 8w15 */
   
   integer	i;
   integer 	addr;
   integer 	data_was_read;
   integer 	data_to_write;
   
   /* we need clocks */
   wire [10:1] tn;
   wire        t_romn;
   wire        A_stolb;
   wire        t_RASn;
   wire        t_CASn;
   wire        t_RAM_WRn;
   wire [3:0]  t_num;

   reg 	       clk; /* 10Mhz clock */
   reg 	       init;/* positive */

   integer     cycle;/* machine cycle counter */

   /* clock source */
   clocks2 name(	.xtal_in(clk),
			.init(init),
			.tn(tn),
			.t_romn(t_romn),
			.A_stolb(A_stolb),
			.t_RASn(t_RASn),
			.t_CASn(t_CASn),
			.t_RAM_WRn(t_RAM_WRn),
			.t_num(t_num));

   wire [15:0] _10wn;
   reg [44:1]  En;

   /* only for 10w1 */
   uCode_dec ucdec(
		   .En(En),
		   .main_clk(clk),
		   .tn(tn),
		   ._10wn(_10wn));
   
   /* ALU registers */
   reg [3:0]   A1n;
   reg [3:0]   A2n;
   reg [3:0]   A3n;
   reg [3:0]   A4n;

   wire [15:0] ADDR_n;
   assign ADDR_n = {A4n, A3n, A2n, A1n};

   reg [3:0]   sigma_bus;
   reg [3:0]   Z2;
   reg [3:0]   Z3;

   wire [3:0]  X_bus;
   wire [3:0]  Y_bus;

   wire        MXn;
   wire        MYn;
   wire [15:0] VA;    // virtual memory address
   wire [16:0] MA;    // physical memory address

   /* device under test */
   ram dut(
	   .ram_clk(clk),
	   .Addr_n(ADDR_n),
	   .Data(sigma_bus),
	   .Z2(Z2),
	   .Z3(Z3),
	   ._10wn(_10wn),
	   .tn(tn),
	   .En(En),							
	   .Y(Y_bus),
	   .X(X_bus),
	   .MXn(MXn),
	   .MYn(MYn),
	   .VA(VA),
	   .MA(MA));

   /* test events */
   event       test_write_page_regs;
//   event       test_ram_read;
   event       test_ram_write_then_read;

   /* task clears the En bus */
   task clear_En_bus;
      begin
	 @(negedge tn[1]) begin
	    En[44:1] = ~(44'd0);
	 end
      end
   endtask

   /* zeroes page registers */
   task write_page_regs;
      input [3:0] _An1;
      input [3:0] _An2;
      input [3:0] _Z2;
      input [3:0] _Z3;
      begin
	 /* do not activate 10w1 */
	 En[44:1] = ~(44'd0);
	 
	 /* ram operation UAOZU */	
	 En[20:17] = 4'b0110; // 8w9

	 @(negedge tn[1]) begin
	    A1n = _An1;
	    A2n = _An2;
	    Z2 = _Z2;
	    Z3 = _Z3;
	 end
	
	 @(negedge tn[7]) begin
	    En[44:1] = ~(44'd0);
	    En[28:25] = 4'b0111;
	/* ram operation write page reg */	
	    En[20:17] = 4'b0000; // 8w15
	 end
	 #1; /* continues at next cycle */
	 @(negedge tn[7]) begin
	    En[44:1] = ~(44'd0);
	 end
	 @(posedge tn[10]) begin
	 end
      end
   endtask

/* step by step to read byte */
/*
 -t7: set A1n..A4n, Z2, Z3 with the desired address
 set needed En bits
 -t8: UAOZU
 
 wait for t4 of the next cycle
 -t4: read ram data at rising edge -t4
*/
   task read_byte_16b_addr;
      input [15:0] address;
      input [3:0]  operation; // directly goes to En[]
      input [7:0]  expected;
      output [7:0] data;
      
      begin
	 @(posedge tn[1]) begin
	    En[20:17] = 4'b1111;
	 end
	 @(negedge tn[5]) begin
	    if (operation == ram_operation_CA1) begin
	       A1n = ~(address[15:12]);
	       A2n = ~(address[11:8]);
	       Z2 = address[7:4];
	       Z3 = address[3:0];
	    end else if (operation == ram_operation_CA3) begin
	       A3n = ~(address[15:12]);
	       A4n = ~(address[11:8]);
	       Z2 = address[7:4];
	       Z3 = address[3:0];
	    end else begin
	       $display("Bad address mode provided!\n");		
	       $finish;
	    end
	 end
	 @(negedge tn[7]) begin
	    En[20:17] = operation; /* Ex gets new from ROM */
	 end
	 @(posedge tn[4]) begin
	    data = {Y_bus, X_bus};
	    if (data != expected ) begin
	       $display("RAM read error at address %d, MA %d, expected %d, read %d\n", address, dut.MA, expected, data);
	       #10;
	       $finish;
	    end
	 end
	 #1;
	 @(posedge tn[10]) begin /* wait for cycle end */
	end
	 
	end
   endtask

   /* step by step to write byte */
   /*
    -t1: set A1n..A4n, Z2, Z3 with the desired address
    set needed En bits
    wait for t4
    -t4: read ram data at rising edge -t4
    */
   task write_byte_16b_addr;
      input [15:0] address;
      input [3:0]  operation_addr_set; // directly goes to En[]
      input [3:0]  operation_write;    // directly goes to En[]
      input [7:0]  in_data;
      
      begin
	 data_to_write = in_data;	 
	 @(posedge tn[1]) begin
	    En[20:17] = 4'b1111;
	 end
	 /* 1st machine cycle - set address */
	 @(negedge tn[5]) begin
	    if (operation_addr_set == ram_operation_CA1) begin
	       A1n = ~(address[15:12]);
	       A2n = ~(address[11:8]);
	       Z2 = address[7:4];
	       Z3 = address[3:0];
	    end else if (operation_addr_set == ram_operation_CA3) begin
	       A3n = ~(address[15:12]);
	       A4n = ~(address[11:8]);
	       Z2 = address[7:4];
	       Z3 = address[3:0];
	    end else begin
	       $display("Bad address mode provided!\n");		
	       $finish;
	    end
	 end
	 @(negedge tn[7]) begin
	    En[20:17] = operation_addr_set; /* Ex gets new from ROM */
	    if ((operation_write == ram_operation_ZPCY) || ( operation_write == ram_operation_ZPY)) begin
	       sigma_bus = in_data[7:4];
	    end
	    else if (((operation_write == ram_operation_ZPCX) || ( operation_write == ram_operation_ZPX))) begin
	       sigma_bus = in_data[3:0];
	    end else begin
	       $display("Bad nibble mode provided!\n");		
	       $finish;
	    end
	 end
	 /* 2nd machine cycle - set operation "write" */
	 #1;
	 @(negedge tn[7]) begin
	    En[20:17] = operation_write;
	 end
	 #1;
	 /* 3rd machine cycle - writing 1st nibble  and preparing the 2nd  nibble */
	 @(negedge tn[7]) begin
	    case (operation_write)
	      ram_operation_ZPCY : begin
	 	 $display("ZPCY -> ZPCX\n");		 
		 sigma_bus = in_data[3:0];
		 operation_write = ram_operation_ZPCX;
	      end
	      ram_operation_ZPY : begin
	 	 $display("ZPY -> ZPX\n");		 		 
		 sigma_bus = in_data[3:0];
		 operation_write = ram_operation_ZPX;
	      end
	      ram_operation_ZPCX : begin
	 	 $display("ZPCX -> ZPCY\n");		 		 
		 sigma_bus = in_data[7:4];
		 operation_write = ram_operation_ZPCY;
	      end
	      ram_operation_ZPX : begin
	 	 $display("ZPX > ZPY\n");		 		 
		 sigma_bus = in_data[7:4];
		 operation_write = ram_operation_ZPY;
	      end
	      default: $finish;
	    endcase // case (operation_write)
    	    En[20:17] = operation_write;
	 end // @ (negedge tn[7])
	 #1;
	 /* 4th machine cycle - writing the second nibble */
	 @(negedge tn[7]) begin
	    En[20:17] = 4'b1111;	    
	 end
	 @(posedge tn[10]) begin /* wait for cycle end */
	 end
      end
   endtask // write_byte_16b_addr
   
   
   initial begin 
      forever begin
	 @(test_write_page_regs);
	 write_page_regs(4'b1111, 4'b1111, 4'b000,4'b000 );
	 clear_En_bus();
	 @(posedge tn[10]) begin
	 end
	 $display("test_write_page_regs end time = %d\n", $time);
      end 
   end
   
//   initial begin
//      forever begin
//	 @(test_ram_read);
//	 for (addr = 0;addr < 2/*16384*/; addr = addr + 1) begin
//	    read_byte_16b_addr(addr, ram_operation_CA3, (addr ^ (addr << 3)) % 256, data_was_read);
//	 end
//	 $display("test_ram_read time = %d\n", $time);
//	 $finish;	 
//    end
//   end


initial begin
   forever begin
      @(test_ram_write_then_read);
      for (addr = 0;addr < 2/*16384*/; addr = addr + 1) begin
	 write_byte_16b_addr(addr, ram_operation_CA3, ram_operation_ZPY, (addr ^ (addr << 3)) % 256);
      end
      $display("test_ram_write time = %d\n", $time);
      #20;
      for (addr = 0;addr < 2/*16384*/; addr = addr + 1) begin
	 read_byte_16b_addr(addr, ram_operation_CA3, (addr ^ (addr << 3)) % 256, data_was_read);
      end
      $display("test_ram_read time = %d\n", $time);
      $finish;	 
   end
end
   
/* initial values */		
   initial 
     begin
	clk = 1'b0;
	cycle = 1;
	init = 1'b0;
	sigma_bus = 4'b0000;
	Z2 = 4'b0000;
	Z3 = 4'b0000;
	En = ~44'b0;
	A1n = 4'b1111;
	A2n = 4'b1111;
	A3n = 4'b1111;
	A4n = 4'b1111;
	
	# 2 init = 1'b1;
	# 10 init = 1'b0;
	#2147483641 $finish;
     end 

   initial begin
      forever begin
	 #40 -> test_write_page_regs;
	 #10000000;
	end		
   end

   initial begin
      forever begin
	 #200 -> test_ram_write_then_read;
	 #10000000;
	end		
   end

   initial begin
      forever begin
//	 #1320000 -> test_ram_read;
	 #10000000;
	end		
   end


   always #1 clk = ~clk;// + 1'b1;
   
   always @(negedge tn[1] or posedge init) begin
      if (init) cycle = 0;
      else cycle = cycle + 1;
   end
   
endmodule
/*                                   E.O.F.                                        */

