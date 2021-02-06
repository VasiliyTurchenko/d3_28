/* MAX7219-based indicator */

/************************* indicator ************************************************/
/* state machine based version */
module indikator2
    #(parameter  CLK_FREQ = 10_000_000, /* clk_in */
      parameter  NUM_CHIPS = 4)
     (
         /* clk_in and clk may come from different clkcl domains */
         input wire 	     clk_in,
         input wire 	     spi_clk,

         input wire [3:0] data, // 0...f
         input wire [4:0] position,
         input wire 	     wrn, // write to the display by the falling edge
         input wire 	     init, // positive
         input wire [3:0] intensity,

         output wire      SPI_MOSI,
         output wire      SPI_CLK,
         output reg 	     SPI_CS,
         output reg 	     OE, // this is needed for odd level shifter
         output reg 	     indikator_ready, /* for upper level logic */
         //    output reg 	     test_out
         output wire      test_out
     );

    localparam BUFFER_LEN = NUM_CHIPS * 8;
    localparam POS_BUS_WIDTH = log2(BUFFER_LEN);

    /* refresh display every 10 ms */
    localparam REF_COUNT =  CLK_FREQ / 100;
    //   localparam  REF_COUNT = 500;

    localparam REF_CNT_WIDTH = log2(REF_COUNT);

    /*   NUM_CHIPS is a number of the 7219 cips in the daisy chain */
    localparam CHIP_CNT_WIDTH = log2(NUM_CHIPS);

    initial
    begin
        $display("CLK_FREQ = %d", CLK_FREQ);
        $display("REF_COUNT = %d", REF_COUNT);
        $display("BUFFER_LEN = %d", BUFFER_LEN);
        $display("REF_CNT_WIDTH = %d", REF_CNT_WIDTH);
        $display("POS_BUS_WIDTH = %d,",POS_BUS_WIDTH);
        $display("CHIP_CNT_WIDTH = %d,",CHIP_CNT_WIDTH);
    end

    /* crossing clock domains */
    wire [3:0] data_s; // syncronous data
    wire [POS_BUS_WIDTH-1:0] position_s;
    wire 		    wrn_s;

    xclockd #(.BUS_WIDTH(4)) _datam(.in(data),
                                    .out(data_s),
                                    .clk(clk_in));

    xclockd #(.BUS_WIDTH(POS_BUS_WIDTH)) _posm(.in(position),
            .out(position_s),
            .clk(clk_in));

    xclockd #(.BUS_WIDTH(1)) _wrnm(.in(wrn),
                                   .out(wrn_s),
                                   .clk(clk_in));

    reg [3:0] 		    buffer [0:BUFFER_LEN - 1];// display memory
    integer 		    i;

    assign test_out = wrn_s;

    always @(negedge wrn_s or posedge init)
    begin
        if (init)
        begin
            // clear mem
            for (i = 0; i < BUFFER_LEN ; i = i + 1)
            begin
                buffer[i] <= 4'hf; // blank position
            end
        end
        else if (~wrn_s)
        begin
            buffer[position_s] <= data_s;
        end
    end

    /* derive scan clock */
    reg [REF_CNT_WIDTH-1:0] div_cnt;
    reg 			   scan_clk;

    always @(posedge clk_in or posedge init)
    begin
        if (init)
        begin
            div_cnt <= REF_COUNT;
            scan_clk <=1'b0;
        end
        else if (clk_in)
        begin
            if (div_cnt == 20'h0)
            begin
                scan_clk <= ~scan_clk;
                div_cnt <= REF_COUNT;
            end
            else
            begin
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

    /* states for state machine */
    localparam STATE_PREP_INIT = 1; // uninitialized, prepare initialisation data
    localparam STATE_PREPARE_REGULAR_SCAN = STATE_PREP_INIT + 1;
    localparam STATE_CALC_BA = STATE_PREPARE_REGULAR_SCAN + 1;
    localparam STATE_LOAD_DR = STATE_CALC_BA + 1;    
    localparam STATE_WRITE_CHIP = STATE_LOAD_DR + 1; // print out the same char position to all chips
    localparam STATE_CHECK_COLUMN = STATE_WRITE_CHIP + 1;    
    localparam STATE_PREPARE_NEXT_POS = STATE_CHECK_COLUMN + 1; // prepare data for the next position
    localparam STATE_END_SCAN = STATE_PREPARE_NEXT_POS + 1;
    localparam STATE_WAIT_SPI = STATE_END_SCAN + 1;

    reg [4:0] target_state; // target state
    reg [4:0] return_state; // where to return from wait state
    reg [7:0] pos_cnt; // position counter
    reg [15:0] DR; // data out register
    reg [POS_BUS_WIDTH-1 :0] BA; // screeen buffer address
    reg [CHIP_CNT_WIDTH-1:0] chip_cnt_col;      // chip counter for payload (column)
    reg [CHIP_CNT_WIDTH-1:0] chip_cnt_row; // dummy counter (row)
    reg 			    initialized;
    reg 			    start; // command for SPI
    wire 		    txe;   // status of the SPI, 1 - spi is ready to transmit
    wire 		    txe_in;   // status of the SPI, 1 - spi is ready to transmit
    reg [11:0] 		    configs [0:4]; // configuration data
    reg [7:0] 		    upper_pos_limit; // 5 or 8 depends of init or run

    always@(posedge init or posedge clk_in)
    begin
        if (init)
        begin
            target_state <= STATE_PREP_INIT;
            indikator_ready <= 1'b0;
            initialized <= 1'b0;
            SPI_CS <= 1'b1;
        end
        else if (clk_in)
        begin
            case (target_state)
                STATE_PREP_INIT:
                begin
                    pos_cnt <= 8'h00;
                    chip_cnt_col <= 0;
                    chip_cnt_row <= 0;
                    DR <= 16'h0000;
                    BA <= 0;
                    OE <= 1'b1;
                    configs[0] <= 12'b1001_1111_1111; // decode 8 digits // 2559
                    configs[1] <= {8'b1010_0000, intensity}; // intensity	// 2568
                    configs[2] <= 12'b1011_0000_0111; // scan all the positions //2823
                    configs[3] <= 12'b1100_0000_0001; // normal op // 3073
                    configs[4] <= 12'b1111_0000_0000; // no display test // 3840
                    return_state <= 4'b0000;
                    start <= 1'b0;
                    upper_pos_limit <= 8'h5;
                    if (scan_pulse)
                    begin
                        target_state <= STATE_CALC_BA;
                    end
                    else
                        target_state <= STATE_PREP_INIT;
                end // case: STATE_PREP_INIT

                STATE_PREPARE_REGULAR_SCAN:
                begin
                    BA <= 0;
                    pos_cnt <= 0;
                    chip_cnt_col <= 0;
                    chip_cnt_row <= 0;
                    if (scan_pulse)
                    begin
                        target_state <= STATE_CALC_BA;
                    end
                    else
                        target_state <= STATE_PREPARE_REGULAR_SCAN;
                end // STATE_PREPARE_REGULAR_SCAN

                STATE_CALC_BA:
                begin
                    if (pos_cnt == upper_pos_limit)
                        target_state <= STATE_END_SCAN;
                    else
                    begin
                        if (chip_cnt_col == 0)
                            SPI_CS <= 1'b0;
                        BA <= {chip_cnt_col,pos_cnt[2:0]};
                        target_state <= STATE_LOAD_DR;
                    end
                end //STATE_CALC_BA

                STATE_LOAD_DR:
                begin
                    if (chip_cnt_col == chip_cnt_row)
                    begin
                        if (~indikator_ready)
                        begin
                            DR <= configs[pos_cnt]; // it's initialisation
                        end
                        else
                        begin
                            DR <= {4'b0000, (pos_cnt[3:0] & 4'b0111) + 1'b1, 4'b0000, buffer[BA]}; /* buffer output */
                        end
                    end
                    else
                    begin
                        DR <= 16'h0000;
                    end
                    target_state <= STATE_WRITE_CHIP;
                end // STATE_CALC_BA

                STATE_WRITE_CHIP:
                begin
                    if ((txe & start) | (~txe))
                    begin
                        return_state <= STATE_WRITE_CHIP;
                        target_state <= STATE_WAIT_SPI;
                    end
                    else
                    begin
                        $display("chip_cnt = %d, pos_cnt = %d, BA = %d, DR = %h\n", chip_cnt_col, pos_cnt, BA, DR);
                        start <= 1'b1;
                        chip_cnt_col <= chip_cnt_col + 1'b1;
                        target_state <= STATE_CHECK_COLUMN;
                    end
                end // STATE_WRITE_CHIP

                STATE_CHECK_COLUMN:
                begin
                    if ((txe & start) | (~txe))
                    begin
                        return_state <= STATE_CHECK_COLUMN;
                        target_state <= STATE_WAIT_SPI;
                    end
                    else if (chip_cnt_col == NUM_CHIPS)
                    begin
                        chip_cnt_col <= 0;
                        SPI_CS <= 1'b1;
                        chip_cnt_row <= chip_cnt_row + 1'b1;
                        target_state <= STATE_PREPARE_NEXT_POS;
                    end
                    else
                        target_state <= STATE_CALC_BA;
                end // STATE_CHECK_COLUMN

                STATE_PREPARE_NEXT_POS:
                begin
                    if (chip_cnt_row == NUM_CHIPS)
                    begin
                        pos_cnt <= pos_cnt + 1'b1;
                        chip_cnt_row <= 0;
                    end
                    target_state <= STATE_CALC_BA;
                end // STATE_PREPARE_NEXT_POS

                STATE_END_SCAN:
                begin
                    if ((txe & start) | (~txe))
                    begin
                        return_state <= STATE_END_SCAN;
                        target_state <= STATE_WAIT_SPI;
                    end
                    else
                    begin
                        /* first run means intitialisation sequence */
                        upper_pos_limit <= 8'h8;
                        indikator_ready <= 1'b1;
                        target_state <= STATE_PREPARE_REGULAR_SCAN;
                        //		 test_out <= 1'b0;
                    end
                end // STATE_END_SCAN

                STATE_WAIT_SPI:
                begin
                    if (txe & start)
                        target_state <= STATE_WAIT_SPI;
                    else if (~txe)
                    begin
                        start <= 1'b0;
                        target_state <= STATE_WAIT_SPI;
                    end
                    else
                    begin
                        target_state <= return_state;
                    end
                end // STATE_WAIT_SPI

            endcase
        end // of       else if (clk_in)
    end // always@ (posedge init or posedge clk_in)

    xclockd #(.BUS_WIDTH(1)) txe_xc(.in(txe_in),
                                    .out(txe),
                                    .clk(clk_in));
    spi_out #(.CLK_POL(0)) spi_impl(
                .DR(DR),
                .init(init),
                .clk4(spi_clk),
                .start(start),
                .txe(txe_in),
                .MOSI(SPI_MOSI),
                .SPI_CLK(SPI_CLK),
                .SPI_CS(/*SPI_CS*/) );

    function integer log2(input integer value);
        begin
            for (log2=0; value>0; log2=log2+1)
                value = value >> 1;
        end
    endfunction

endmodule // indikator

/****************************** TEST BENCH ********************************/

module indikator2_test();

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
    wire 	 ind_rdy;

    indikator2 dut(
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
                   .OE(OE),
                   .indikator_ready(ind_rdy)
               );

    initial
    begin
        data <= 0;
        pos <= 0;
        init <= 1'b0;
        clk_in <= 1'b0;
        spi_clk <= 1'b0;
        wrn <= 1'b1;
        intensity <= 4'b011;
        # 2 init = 1'b1;
        # 5 init = 1'b0;
        #80000 $finish;
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
