/* Toplevel for the entrie design */

module D3_28(
        input wire 	ext_clk, // external xtal generator connection
        input wire 	ext_reset_n, // hardware resrt button

        output wire [10:1] tn, // for test purposes
        output reg 	MHZ_10,

        /* 7 segment led interface */
        //	output wire [7:0] pos,
        //	output wire [7:0] char,

        output wire [7:0] 	io_addr,
        output wire [7:0] 	io_data,
        output wire 	SIMn,
        output wire 	VV,

        /* test output */
        output wire 	test_point,

        /* SPI indicator */
        output wire 	SPI_MOSI,
        output wire 	SPI_CLK,
        output wire 	SPI_CS,
        output reg 	OE
    );

    /* devboard PS-06 has 50MHz oscillator connected to the pin 23 */
    /* we have to obtain 10MHz clock */
    reg [3:0] 			div;
    initial
        div = 4'b0100;
    initial
        MHZ_10 = 1'b0;

    always @(posedge ext_clk)
    begin
        if (div == 0)
        begin
            MHZ_10 <= 1'b0;
            div <= 4'b0100;
        end
        else
            div <= div - 1;
        if (div == 4'b0010)
            MHZ_10 <= 1'b1;
    end

    wire init_master;

    machine impl(
                .xtal_clk(MHZ_10),
                .init_ext(ext_reset_n),
                .tn(tn),
                .init_master(init_master),

                .SIMn(SIMn),
                .VV(VV),
                .Y3n(io_addr[7:4]),
                .X3n(io_addr[3:0]),

                .Y2n(io_data[7:4]),
                .X2n(io_data[3:0]),
                .test_point()
            );

    /* test for 7 segment led */
    reg [23:0] div_sec;
    initial
        div_sec = 24'd1_000_000;
    reg 	      one_sec_pulse;

    always @ (posedge MHZ_10)
    begin
        if (div_sec == 24'd0)
        begin
            one_sec_pulse <= ~one_sec_pulse;
            div_sec <=  24'd1_000_000;
        end
        else
            div_sec <= div_sec - 1'b1;
    end

    //	assign test_point = one_sec_pulse;

    reg [3:0] outchar;
    reg [4:0] pos_counter;
    wire      new_datam;

    always @(posedge one_sec_pulse or posedge init_master)
    begin
        if (init_master)
        begin
            outchar <= 4'h0;
            pos_counter <= 4'b00000;
        end
        else if (one_sec_pulse)
        begin
            outchar <= (outchar + 1'b1)%15;
            pos_counter <= pos_counter + 1'b1;
        end
    end


    /*
    	led7x8 led7x8__impl(.clk_in(MHZ_10), .init(init_master),
    							  .data(outchar), .addr(pos_counter),
    							  .seg(char), .pos(pos), .wrn(wrn));
     */
    //   reg [3:0] data;
    //   reg [4:0] position;
    //   reg 	     wrn;  // write to the display by the falling edge
    reg [3:0] intensity;
    reg [1:0] div4;
    reg 	     sc;

    always @(posedge init_master)
    begin
        //      data <= 4'hf;
        //      position <= 0;
        //      wrn <= 1'b1;
        intensity <=  4'b0010;
        OE <= 1'b1;
    end

    initial
        div4 = 2'b11;
    initial
        sc = 0;

    always@(posedge MHZ_10)
    begin
        div4 <= div4 - 1'b1;
        if (div4 == 2'b00)
        begin
            sc <= ~sc;
            div4 <= 2'b11;
        end
    end

    xclockd #(.BUS_WIDTH(1)) _wrnm(.in(one_sec_pulse),
                                   .out(new_datam),
                                   .clk(sc));

    reg new_dataf;
    always @(posedge sc)
    begin
        new_dataf <= new_datam;
    end

    wire wrn;
    assign wrn = ~(new_datam & ~new_dataf);
    //   assign test_point = wrn;


    indikator2 #(.CLK_FREQ(1_250_000)) indikator_impl(
                   .clk_in(sc),
                   .spi_clk(MHZ_10),
                   .data(outchar),
                   .position(pos_counter),
                   .wrn(wrn),
                   .init(init_master),
                   .intensity(intensity),
                   .SPI_MOSI(SPI_MOSI),
                   .SPI_CLK(SPI_CLK),
                   .SPI_CS(SPI_CS),
                   .test_out(test_point) );

    //	assign test_point = io_data[0];

endmodule

/*  test */
`timescale 10ns/1ns
module top_test();
    reg ext_clk;
    wire mhz_10;

    D3_28 DUT(.ext_clk(ext_clk), .MHZ_10(mhz_10));

    initial
    begin
        ext_clk = 1'b0;
        #200 $finish;
    end

    always #1 ext_clk = ~ext_clk;

endmodule
