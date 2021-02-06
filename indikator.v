/* MAX7219-based indicator */

/* spi n bit */
module spi_out
  #(parameter NUM_BITS = 16,
    parameter MOSI_POL = 0,
    parameter CLK_POL = 0)
   (
    input wire [NUM_BITS-1:0] DR,
    input wire 		      clk4, //  spi clk * 4
    input wire 		      init,
    input wire 		      start,
    output reg 		      txe,
    output reg 		      MOSI,
    output reg 		      SPI_CLK,
    output reg 		      SPI_CS  );
   
   localparam integer 	      BITCOUNT_WIDTH = log2(NUM_BITS);
   
   initial begin
      $display("NUM_BITS = %d", NUM_BITS);
      $display("MOSI_POL = %d", MOSI_POL);
      $display("CLK_POL = %d,", CLK_POL);
      $display("BITCOUNT_WIDTH = %d,",BITCOUNT_WIDTH);
   end
   
   wire 		       start1;
   xclockd #(.BUS_WIDTH(1)) st(.in(start),
			       .out(start1),
			       .clk(clk4));
   
   wire [NUM_BITS-1:0] 	       DR1;
   xclockd #(.BUS_WIDTH(NUM_BITS)) dxd (.in(DR),
					.out(DR1),
					.clk(clk4));
   
   wire 		       go;
   assign go = ~start1 & start;

   
   reg [NUM_BITS-1:0] 	       TXR;
   reg [BITCOUNT_WIDTH-1:0]    bitcount;
   reg [1:0] 		       phase;
   
   always@(posedge init or posedge clk4 or posedge go) begin
      if(init) begin
	 TXR <= 0;
	 MOSI <= MOSI_POL;
	 SPI_CLK <= CLK_POL;
	 SPI_CS <= 1'b1;
	 txe <= 1'b1;
	 phase <= 2'b00;
      end
      else if (go) begin
	 TXR<= DR1;
	 SPI_CS <= 1'b0;
	 bitcount <= NUM_BITS;
	 txe <= 1'b0;
	 phase <= 2'b00;
      end
      else if (clk4) begin
	 if (bitcount >0) begin
	    case (phase)
	      2'b00 : begin // set data line
		 MOSI <= TXR[NUM_BITS-1] ^ MOSI_POL;
		 TXR <= TXR << 1'b1 | 1'b0;
	      end
	      2'b01 : SPI_CLK <= ~CLK_POL;
	      2'b10 : SPI_CLK <= ~CLK_POL;
	      2'b11 : begin 
		SPI_CLK <= CLK_POL;
		bitcount = bitcount - 1'b1;	 
		end
	    endcase // case (phase)
	    phase <= phase + 1'b1;
	 end   
	 else begin
	    MOSI <= MOSI_POL;
	    SPI_CLK<= CLK_POL;
	    SPI_CS <= 1'b1;
	    txe <= 1'b1;
	 end
      end
   end
function integer log2(input integer value);
   begin
      for (log2=0; value>0; log2=log2+1)
         value = value >> 1;
   end
endfunction

endmodule // spi_out

/*************** TEST BENCH *************************************/
`timescale 10ns/1ns
module spi_out_test();

   localparam NB = 16;
   localparam NBW = log2(NB);
   reg [NB-1:0] DR;
   reg 		 init;
   reg 		 clk;
   reg 		 start;
   wire 	 MOSI;
   wire 	 SPI_CLK;
   wire 	 SPI_CS;
   wire		 txe;

   integer 	 data;

   spi_out #(.CLK_POL(0)) dut(
	       .DR(DR),
	       .init(init),
	       .clk4(clk),
	       .start(start),
		.txe(txe),
	       .MOSI(MOSI),
	       .SPI_CLK(SPI_CLK),
	       .SPI_CS(SPI_CS) );

   event 	 start_sending;

   /* send word */
   task send_word;
      input [NB-1:0] dts;
      begin
	 DR = dts;
	 start <= 1'b1;
	 #2;
	 start <= 1'b0;
	 @(posedge txe) begin
	 end
      end
   endtask // send_word
   
   initial begin
      DR <= 0;
      init <= 1'b0;
      clk <= 1'b0;
      start <= 1'b0;
      # 2 init = 1'b1;
      # 5 init = 1'b0;
      #1000000 $finish;
   end

   initial begin
      forever begin
      @(start_sending);
      for (data = 16'hF5A1; data < 16'hF5AF; data = data + 1) begin
	 send_word(data);
	#2;
      end
	$finish;
      end
   end

   always #1 clk = ~clk;

   initial begin
      forever begin
	 #10 -> start_sending;
	 #10000000;
	end		
   end

function integer log2(input integer value);
   begin
      for (log2=0; value>0; log2=log2+1)
         value = value >> 1;
   end
endfunction
  
endmodule // spi_out_test

/************************* indicator ************************************************/
module indikator 
  #(parameter  CLK_FREQ = 10_000_000,
    parameter  NUM_CHIPS = 2)
   (
    input wire 	     clk_in,
    input wire 	     spi_clk, 
    input wire [3:0] data, // 0...f
    input wire [4:0] position,
    input wire 	     wrn, // write to the display by the falling edge
    input wire 	     init, // positive
    input wire [3:0] intensity,
    
    output wire      SPI_MOSI,
    output wire      SPI_CLK,
    output wire      SPI_CS,
    output reg 	     OE
    );
   
   localparam BUFFER_LEN = NUM_CHIPS * 8;
   localparam POS_BUS_WIDTH = log2(BUFFER_LEN);
   
   /* clk_in periods for 1us */

   localparam real 		   COUNT = 0.000001 * CLK_FREQ;
 /* refresh display every 10 ms */
//   localparam real 		   REF_COUNT =  COUNT * 10_000 / 20;
localparam  REF_COUNT = 500;

   localparam REF_CNT_WIDTH = log2(REF_COUNT);
   
   /*   NUM_CHIPS is a number of the 7219 cips in the daisy chain */
   localparam CHIP_CNT_WIDTH = log2(NUM_CHIPS);
   
   initial begin
      $display("CLK_FREQ = %d", CLK_FREQ);
      $display("REF_COUNT = %d", REF_COUNT);
      $display("COUNT for 1us = %d", COUNT);
      $display("BUFFER_LEN = %d", BUFFER_LEN);
      $display("REF_CNT_WIDTH = %d", REF_CNT_WIDTH);
      $display("POS_BUS_WIDTH = %d,",POS_BUS_WIDTH);
      $display("CHIP_CNT_WIDTH = %d,",CHIP_CNT_WIDTH);
   end
   
   wire [3:0] data_s; // syncronous data
   wire [POS_BUS_WIDTH-1 :0] position_s;
   wire 		     wrn_s;
   
   xclockd #(.BUS_WIDTH(4)) _datam(.in(data),
				   .out(data_s),
				   .clk(clk_in));
   
   xclockd #(.BUS_WIDTH(POS_BUS_WIDTH)) _posm(.in(position),
						.out(position_s),
						.clk(clk_in));
   
   xclockd #(.BUS_WIDTH(1)) _wrnm(.in(wrn),
				  .out(wrn_s),
				  .clk(clk_in));
   
   reg [3:0] 		     buffer [0:BUFFER_LEN - 1];// display memory
   integer 		     i;
   
   always @(negedge wrn_s or posedge init) begin
      if (init) begin 
	 // clear mem
	 for (i = 0; i < BUFFER_LEN ; i = i + 1) begin
	    buffer[i] <= i; // blank position
	 end
      end
      else if (~wrn_s) begin
	   buffer[position_s] <= data_s;
      end
   end

   /* derive scan clock */
   reg [REF_CNT_WIDTH-1:0] div_cnt;
   reg 			   scan_clk;
   
   always @(posedge clk_in or posedge init) begin
      if (init) begin
	div_cnt <= REF_COUNT;
	scan_clk <=1'b0;
	end else if (clk_in) begin 
      if (div_cnt == 20'h0) begin
	 scan_clk <= ~scan_clk;
	 div_cnt <= REF_COUNT;
      end
      else begin
	 div_cnt <= div_cnt - 1'b1;
      end
end
   end
   wire sc2;
   xclockd #(.BUS_WIDTH(1)) scan_p(.in(scan_clk),
				  .out(sc2),
				  .clk(clk_in));
    wire scan_pulse;
   assign scan_pulse = ~scan_clk & sc2;
   
   /* initialisation */
   reg initialized;
  
   reg [11:0] configs [4:0];

//   initial configs[0] = 12'b1001_1111_1111; // decode 8 digits // 2559
//   initial configs[1] = 12'b1010_0000_1000; // intensity	// 2568
//   initial configs[2] = 12'b1011_0000_0111; // scan all the positions //2823
//   initial configs[3] = 12'b1100_0000_0001; // normal op // 3073
//   initial configs[4] = 12'b1111_0000_0000; // no display test // 3840
/*
   always@(negedge init) begin
      configs[1][3:0] <= intensity;
   end
*/
   reg [7:0] pos_cnt;
   reg [CHIP_CNT_WIDTH-1:0] chip_cnt;
   reg [15:0] DR; // data out register
   reg 	      start;
   wire       txe;
   reg 	      rdy;
   reg	      mega_cycle_started;
   reg 	      mega_cycle_done; // 1 means all data transferred

   wire [3:0] top_src_addr;
   assign top_src_addr = (initialized) ? 4'd8 : 4'd5;

   reg [POS_BUS_WIDTH-1 :0] BA;

   always@(posedge init or posedge clk_in)begin
      if (init) begin
	 DR <= 15'd0;
	 start <= 0;
	 rdy <= 1'b0;
	 initialized <= 1'b0;
	 chip_cnt <= 0;
	 pos_cnt <= 0;
	 mega_cycle_done <= 1'b1;
	 mega_cycle_started <= 1'b0;
   	configs[0] <= 12'b1001_1111_1111; // decode 8 digits // 2559
	configs[1] <= {8'b1010_0000, intensity}; // intensity	// 2568
	configs[2] <= 12'b1011_0000_0111; // scan all the positions //2823
	configs[3] <= 12'b1100_0000_0001; // normal op // 3073
	configs[4] <= 12'b1111_0000_0000; // no display test // 3840
	BA <= 0;
      end
      else if (clk_in) begin
	 start <= 1'b0;
	 if (scan_pulse & mega_cycle_done) begin 
		    /* new megacycle */
		mega_cycle_started <= 1'b1;
		 mega_cycle_done <= 1'b0;
	end
	 if (mega_cycle_started & txe & ~start) begin
	    if (pos_cnt < top_src_addr) begin
	       if (chip_cnt < NUM_CHIPS) begin
	       	  if (~initialized) DR <= configs[pos_cnt];
	       	  else begin
			 BA <= chip_cnt * 8 + pos_cnt;
			 DR <= {pos_cnt + 1'b1, 4'b0000, buffer[BA]}; /* buffer output */
			end
		  $display("chip_cnt = %d, DR = %h", chip_cnt, DR);
		  $display("chip_cnt * 8 + pos_cnt = %d\n", (chip_cnt * 8 + pos_cnt));
		  start <= 1'b1;
		  chip_cnt <= chip_cnt + 1'b1;
	       end
	       else  chip_cnt <= 0;
		if (chip_cnt == NUM_CHIPS) pos_cnt = pos_cnt + 1'b1;
	    end
	    else begin
	       initialized <= 1'b1;
	       mega_cycle_done <= 1'b1;
	       mega_cycle_started <= 1'b0;
	       BA <= 0;
	       pos_cnt <= 0;
	    end // else: !if(pos_cnt < top_src_addr)
	 end 
	 rdy <= txe;

      end // if (clk_in)
   end // always@ (posedge scan_pulse or posedge init or posedge clk_in)
   
   spi_out #(.CLK_POL(0)) spi_impl(
				   .DR(DR),
				   .init(init),
				   .clk4(spi_clk),
				   .start(start),
				   .txe(txe),
				   .MOSI(SPI_MOSI),
				   .SPI_CLK(SPI_CLK),
				   .SPI_CS(SPI_CS) );

function integer log2(input integer value);
   begin
      for (log2=0; value>0; log2=log2+1)
         value = value >> 1;
   end
endfunction
   
endmodule // indikator


/****************************** TEST BENCH ********************************/

module indikator_test();

   localparam NUM_OF_POSITIONS = 32;
   localparam PBW=log2(NUM_OF_POSITIONS);
   
   reg clk_in;
   reg spi_clk;
   reg [3:0] data;
   reg [PBW-2:0] pos;
   reg 		 wrn;
   reg 		 init;
   reg [3:0] 	 intensity;
   wire 	 SPI_MOSI;
   wire 	 SPI_CLK;
   wire 	 SPI_CS;
   wire 	 OE;
   indikator dut(
		 .clk_in(clk_in),
		 .spi_clk(spi_clk),
		 .data(data),
		 .position(pos),
		 .wrn(wrn),
		 .init(init),
		 .intensity(intensity),
		 .SPI_MOSI(SPI_MOSI),
		 .SPI_CLK(SPI_CLK),
		 .SPI_CS(SPI_CS),
		 .OE(OE)
);

   initial begin
	$display("log2(1) = %d", log2(1));
	$display("log2(2) = %d", log2(2));
	$display("log2(4) = %d", log2(4));
	$display("log2(8) = %d", log2(8));
	$display("log2(16) = %d", log2(16));
	$display("log2(32) = %d", log2(32));
      data <= 0;
      pos <= 0;
      init <= 1'b0;
      clk_in <= 1'b0;
      spi_clk <= 1'b0;
      wrn <= 1'b1;
      intensity <= 4'b011;
      # 2 init = 1'b1;
      # 5 init = 1'b0;
      #22000 $finish;
   end

   always #1 spi_clk = ~spi_clk;
   always #4 clk_in = ~clk_in;
   
function integer log2(input integer value);
   begin
      for (log2=0; value>0; log2=log2+1)
         value = value >> 1;
   end
endfunction
  
endmodule // indikator_test
