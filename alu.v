/* This file is a part of D3-28 project                            */
/*******************************************************************/
/***                      ALU                                    ***/
/*******************************************************************/

/* metastability fix */
module xclockd #(parameter  BUS_WIDTH = 8)(
        input clk,
        input wire [(BUS_WIDTH -1) : 0] in,
        output reg [(BUS_WIDTH -1) : 0] out );

    reg  [(BUS_WIDTH -1) : 0] m;

    always@(posedge clk)
    begin
        m <= in;
    end
    always@(posedge clk)
    begin
        out <= m;
    end

endmodule


/* 7474 */
module dff_async (RESET, SET, DATA, Q, Qn, CLK);
    input CLK;
    input RESET, SET, DATA;
    output reg Q, Qn;

    // synopsys one_cold "RESET, SET"
    always @(posedge CLK or negedge RESET or negedge SET)
        if (~RESET)
        begin
            Q <= 1'b0;
            Qn <= 1'b1;
        end
        else if (~SET)
        begin
            Q <= 1'b1;
            Qn <= 1'b0;
        end
        else
        begin
            Q <= DATA;
            Qn <= ~DATA;
        end

    // synopsys translate_off
    always @ (RESET or SET)
        if (RESET + SET == 0)
            $write ("ONE-COLD violation for RESET and SET.");
    // synopsys translate_on
endmodule




/*****************************************************************/
/*                                                               */
/*                   BCD corrector                               */
/*                                                               */
/*****************************************************************/
module bcd_corr(
        input wire [3:0] sum,
        input wire c16,
        input wire E16,
        output wire [3:0] c10,
        output wire CARRY_FL
    );
    wire c2;
    assign c2 = sum[1];

    wire c4;
    assign c4 = sum[2];

    wire c8;
    assign c8 = sum[3];

    wire D19C;
    nand(D19C, ~c2, ~c4);

    wire D24B;
    and(D24B, E16, D19C);

    wire D19B;
    nand(D19B, c8, D24B);

    nand(CARRY_FL, D19B, ~c16);

    wire D24A;
    and(D24A, E16, CARRY_FL);

    wire [3:0] adder3_a;
    wire [3:0] adder3_b;

    assign adder3_a = sum;
    assign adder3_b = {1'b0, D24A, D24A, 1'b0};

    fulladder ADDER3(.a(adder3_a), .b(adder3_b), .c_in(1'b0), .sum(c10));

endmodule

/*****************************************************************/
/*                                                               */
/*               Z0 maker                                        */
/*                                                               */
/*****************************************************************/

module Z0_maker(
        input wire [3:0] alu_sigma_bus_n,
        input wire t5n,
        input wire [7:0] _3wn,
        input wire [15:0] _10wn,
        //	input wire [15:0] _10w,

        output wire [3:0] Z0
    );

    wire _3w0;
    assign _3w0 = ~(_3wn[0]);

    wire sigma0n;	// low when all bits of sigma_bus_n == 1 (logical 0)
    nand(sigma0n, alu_sigma_bus_n[0], alu_sigma_bus_n[1], alu_sigma_bus_n[2], alu_sigma_bus_n[3]);

    wire sigma0;
    not(sigma0, sigma0n);

    wire rZ80;
    wire rZ40;
    wire rZ20;
    wire rZ10;

    wire D1D;
    nand(D1D, ~t5n, ~_10wn[2]);
    wire D53A;
    and(D53A, _10wn[15], D1D);

    wire D53D;
    and(D53D, _10wn[14], D1D);

    wire D53B;
    and(D53B, ~(~_10wn[5] & sigma0), _10wn[9]);

    wire D53C;
    and(D53C, (D1D & ~(~_10wn[5] & sigma0n)), _10wn[13]);

    wire D52C;
    and(D52C, _10wn[8], ~(~_10wn[4] & sigma0n));

    wire D52D;
    and(D52D, (D1D & ~(~_10wn[4] & sigma0)), _10wn[12]);

    dff_async	tZ10(.RESET(D52C), .SET(D52D), .DATA(alu_sigma_bus_n[0]), .Qn(rZ10), .CLK(_3w0));
    dff_async	tZ20(.RESET(D53B), .SET(D53C), .DATA(alu_sigma_bus_n[1]), .Qn(rZ20), .CLK(_3w0));
    dff_async	tZ40(.RESET(_10wn[10]), .SET(D53D), .DATA(alu_sigma_bus_n[2]), .Qn(rZ40), .CLK(_3w0));
    dff_async	tZ80(.RESET(_10wn[11]), .SET(D53A), .DATA(alu_sigma_bus_n[3]), .Qn(rZ80), .CLK(_3w0));

    assign Z0 = {rZ80, rZ40, rZ20, rZ10};
endmodule

/*****************************************************************/
/*                                                               */
/*               The main adder                                  */
/*                                                               */
/*****************************************************************/

module main_adder(
        input wire [3:0] alpha,
        input wire [3:0] beta,
        input wire [44:1] En,					/* microcode command bus input */
        input wire alu_clk,
        input wire ZPR4,

        output reg [3:0] alu_out_bus,
        output reg [3:0] alu_out_bus_n,
        output wire P2,
        output reg P3,
        output reg P4
    );

    wire [3:0] sigma;
    wire carry_in;
    wire carry;
    fulladder ADDER(.a(alpha), .b(beta), .c_in(carry_in), .sum(sigma), .c_out(carry));


    /* BCD corrector */
    wire [3:0] c10;
    wire CARRY_FL;
    bcd_corr bcd_corr_impl(.sum(sigma), .c16(carry), .E16(~En[16]), .CARRY_FL(CARRY_FL), .c10(c10));

    /* 4w decoder */
    wire [7:0] _4wn;
    ic74155 _4wdecoder(.ea1(En[10]), .ea2(1'b0),
                       .eb1(1'b0), .eb2(En[10]),
                       .a0(En[12]), .a1(En[11]),

                       .q1(_4wn[3]), .q2(_4wn[2]),
                       .q3(_4wn[1]), .q4(_4wn[0]),
                       .q5(_4wn[7]), .q6(_4wn[6]),
                       .q7(_4wn[5]), .q8(_4wn[4]) );


    nand(carry_in, _4wn[1], _4wn[4], ~(~_4wn[3] & P3));

    wire ZPR3;
    nand(ZPR3, ~En[4], ~(_4wn[7] & _4wn[4] & _4wn[2] & _4wn[3]));

    wire D39B;
    or(D39B, (sigma[0] & ~_4wn[7]), (CARRY_FL & _4wn[7]));	// do not use NOR

    assign P2 = D39B;

    always @(posedge ZPR3)
        P3 <= D39B;

    always @(posedge ZPR4)
        P4 <= D39B;

    /* sigma bus maker */

    wire [3:0] src0;
    assign src0 = { P3, sigma[3], sigma[2], sigma[1]};
    wire [3:0] src1;
    assign src1 = alpha ^ beta;
    wire [3:0] src2;
    assign src2 = alpha & beta;
    wire [3:0] src3;
    assign src3 = c10;

    wire sig_a0;
    nand(sig_a0, ~En[10], ~En[12]);
    wire sig_a1;
    nand(sig_a1, ~En[10], ~En[11]);

    wire [3:0] sigma_not_latched;
    wire [3:0] sigma_not_latched_n;

    mux4to1_4b_e sigma_maker(
                     .i0(src0),
                     .i1(src1),
                     .i2(src2),
                     .i3(src3),
                     .a0(sig_a0),
                     .a1(sig_a1),
                     .en(1'b0),
                     .q(sigma_not_latched),
                     .qn(sigma_not_latched_n)
                 );

    always @(posedge alu_clk)
    begin
        alu_out_bus <= sigma_not_latched;
        alu_out_bus_n <= sigma_not_latched_n;
    end

endmodule


/*****************************************************************/
/*                                                               */
/*               The ALU itself                                  */
/*                                                               */
/*****************************************************************/
module alu_unit(
        input alu_clk,								/* main clock */

        output wire [3:0] alu_sigma_bus, 		/* ALU output data bus */
        output wire [3:0] alu_sigma_bus_n, 	/* ALU output data bus inverted*/

        output wire [15:0] ADDR_n,				/* address bus */

        input wire [44:1] En,					/* microcode command bus input */

        input wire [10:1] tn,					/* clock input */

        input wire [7:0] _1wn,
        input wire [7:0] _3wn,
        input wire [15:0] _8wn,
        input wire [15:0] _10wn,
        input wire [3:0] Y_bus,					/* Y bus comes from high RAM nibble */
        input wire [3:0] X_bus,					/* X bus comes from low RAM nibble */

        input wire RAM_READ,

        /* ALU registers made output for tests */
        output wire [3:0] Z0,

        output reg [3:0] Z1,
        output reg [3:0] Z2,
        output reg [3:0] Z3,

        output reg [3:0] Z6,						/* periph. out reg */
        output reg [3:0] Z7,						/* RAM read reg */

        output reg [3:0] M,						/* ext. IRQ mask reg */

        output reg [3:0] UK,

        /* Z4 and Z5 made as registers in the io.v */
        input wire [3:0] Z4,					/* keyboard or periph. read reg */
        input wire [3:0] Z5,					/* keyboard or periph. read reg */

        output wire P3,
        output wire P4,
        output wire P2,

        input wire EXTI1_n,
        input wire EXTI2_n,
        input wire EXTI4_n,
        input wire EXTI8_n,

        input wire step,	/* step mode */
        input wire V_PR,
        input wire P_PRm,

        /* ext. device connection (open collector) */
        output wire [3:0] EXTI_M_n
    );

    /* Z0 reg */
    Z0_maker Z0_maker_impl(
                 .alu_sigma_bus_n(alu_sigma_bus_n),
                 .t5n(tn[5]),
                 ._3wn(_3wn),
                 ._10wn(_10wn),
                 .Z0(Z0) );

    reg [3:0] A1_n;

    always @(negedge _1wn[4])
    begin
        A1_n <= alu_sigma_bus_n;
    end

    reg [3:0] A2_n;

    always @(negedge _1wn[5])
    begin
        A2_n <= alu_sigma_bus_n;
    end

    reg [3:0] A3_n;

    always @(negedge _1wn[6])
    begin
        A3_n <= alu_sigma_bus_n;
    end

    reg [3:0] A4_n;

    always @(negedge _1wn[7])
    begin
        A4_n <= alu_sigma_bus_n;
    end

    assign ADDR_n = {A4_n, A3_n, A2_n, A1_n};

    wire Z6_sel;
    assign Z6_sel = ~((~(~En[8] & ~En[7])) & RAM_READ);

    wire Z6_strobe;
    assign Z6_strobe = ~(~Z6_sel & ~tn[5]) & _3wn[6];

    wire Z7_strobe;
    assign Z7_strobe = ~(~Z6_sel & ~tn[5]) & _3wn[7];

    always @(negedge Z6_strobe)
    begin
        if (Z6_sel)
        begin
            Z6 <= alu_sigma_bus_n;
        end
        else
        begin
            Z6 <= Y_bus;
        end
    end

    always @(negedge Z7_strobe)
    begin
        if (Z6_sel)
        begin
            Z7 <= alu_sigma_bus_n;
        end
        else
        begin
            Z7 <= X_bus;
        end
    end

    /* external interrupts and masking */

    always @(negedge _1wn[3])
    begin
        M <= alu_sigma_bus;
    end

    /* EXTI meta-stability handling */
    wire [3:0] EXTI_B;
    xclockd #(.BUS_WIDTH(4)) EXTI_x(.in({~EXTI8_n, ~EXTI4_n, ~EXTI2_n, ~EXTI1_n}),
                                    .out(EXTI_B),
                                    .clk(alu_clk));

    assign EXTI_M_n = M & EXTI_B;//{(M[3] & ~EXTI8_n), (M[2] & ~EXTI4_n), (M[1] & ~EXTI2_n), (M[0] & ~EXTI1_n)} ;




    /* UK reg */
    wire UK_strobe;
    assign UK_strobe = (~_8wn[15] & ~tn[5]);
    always @(negedge UK_strobe)
    begin
        UK <= alu_sigma_bus;
    end

    /*  Z1, Z2, Z3 reg */
    always @(negedge _3wn[1])
    begin
        Z1 <= alu_sigma_bus;
    end

    always @(negedge _3wn[2])
    begin
        Z2 <= alu_sigma_bus;
    end

    always @(negedge _3wn[3])
    begin
        Z3 <= alu_sigma_bus;
    end

    /* keyboard response */

    // TODO!

    /*---------------- ALU --------------------------------*/

    /* alpha */
    wire [3:0] alpha;

    wire D22D;
    nand(D22D, En[1], En[13]);

    wire [3:0] Zalpha;
    mux8to1_4b_e	Za(.i0(Z7), .i1(Z6), .i2(Z5), .i3(Z4),
                    .i4(Z3), .i5(Z2), .i6(Z1), .i7(Z0),
                    .a0(En[3]), .a1(En[2]), .a2(En[1]), .en(En[13]),
                    .qn(Zalpha));
    wire [3:0] EXTI_UK;
    mux4to1_4b_e Za1(.i0(4'b0000), .i1(EXTI_M_n), .i2(UK), .i3(4'b0000),
                     .a0(En[3]), .a1(En[2]), .en(D22D), .qn(EXTI_UK));

    assign alpha =  ~Zalpha & ~EXTI_UK;


    /* beta */
    wire [3:0] beta1;
    wire [3:0] beta_a;
    /* TODO !*/
    wire [3:0] fl;
    assign fl = {step, V_PR, P_PRm, 1'b0}; /* {Ш, ВПР, ППР, Р1}*/


    wire [3:0] constant;
    assign constant = {~En[21], ~En[22], ~En[23], ~En[24]};

    mux8to1_4b_e BetaA(.i0(~A4_n), .i1(~A3_n), .i2(~A2_n), .i3(~A1_n),
                       .i4(M), .i5(P), .i6(fl), .i7(constant),
                       .a0(En[6]), .a1(En[5]), .a2(En[4]), .en(~En[15]),
                       .qn(beta_a));
    wire [3:0] beta_z;
    mux8to1_4b_e BetaZ(.i0(Z7), .i1(Z6), .i2(Z5), .i3(Z4),
                       .i4(Z3), .i5(Z2), .i6(Z1), .i7(Z0),
                       .a0(En[6]), .a1(En[5]), .a2(En[4]), .en(En[15]),
                       .qn(beta_z));
    assign beta1 = beta_a & beta_z;

    wire [3:0] beta2;
    compl complementer(.D_n(beta1), .BCD_ctrl_n(En[16]), .out(beta2));
    wire [3:0] beta3;
    mux2to1_4b compl_selector(.i0(beta1), .i1(beta2), .a0(En[14]), .q(beta3));

    wire [3:0] beta;
    assign beta = ~beta3;

    main_adder main_adder_impl(
                   .alpha(alpha),
                   .beta(beta),
                   .En(En),					/* microcode command bus input */
                   .ZPR4(_10wn[7]),
                   .alu_clk(alu_clk),
                   .alu_out_bus(alu_sigma_bus),
                   .alu_out_bus_n(alu_sigma_bus_n),
                   .P2(P2),
                   .P3(P3),
                   .P4(P4) );

endmodule


/*****************************************************************/
/*                                                               */
/*                   BCD corrector  test bench                   */
/*                                                               */
/*****************************************************************/

`timescale 10ns/1ns
module bcd_corr_test;

    reg [4:0] sum;
    reg E16;
    wire [3:0] c10;
    wire CARRY_FL;

    bcd_corr name(.sum(sum[3:0]), .c16(sum[4]), .E16(E16), .c10(c10), .CARRY_FL(CARRY_FL));

    initial
    begin
        sum = 1'b0;
        E16 = 1'b0;
        #64 E16 = 1'b1;
        #64 $finish;
    end

    always #2 sum = sum + 1'b1;

    always@(sum or E16)
        $monitor("At time = %t, Sum = %d, c10 = %d, CARRY_FL = %d", $time, sum, c10, CARRY_FL);

endmodule



/*****************************************************************/
/*                                                               */
/*               Z0 maker  tests                                 */
/*                                                               */
/*****************************************************************/
module Z0_maker_test;

    reg clk;
    reg [3:0] alu_sigma_bus;
    reg t5n;
    reg [7:0] _3wn;
    reg [15:0] _10wn;

    wire [3:0] Z0;

    Z0_maker name(
                 .alu_sigma_bus_n(~alu_sigma_bus),
                 .t5n(t5n),
                 ._3wn(_3wn),
                 ._10wn(_10wn),
                 .Z0(Z0) );

    event pulse_3w0_low;

    event force10w2;
    event force10w11;
    event force10w15;

    event force10w10;
    event force10w14;

    event force10w9;
    event force10w13;

    event force10w8;
    event force10w12;

    event force10w5;
    event force10w4;



    initial
    begin
        forever
        begin
            @(pulse_3w0_low);
            _3wn = 8'b11111110;
            #1
             _3wn = 8'b11111111;
        end
    end

    initial
    begin
        forever
        begin
            @(force10w2);
            _10wn = 16'b1111111111111011;
            #1
             t5n = 1'b0;
            #2
             t5n = 1'b1;
            #17
             _10wn = 16'b1111111111111111;
        end
    end

    initial
    begin
        forever
        begin
            @(force10w11);
            _10wn = 16'b1111_0111_1111_1111;
            #20
             _10wn = 16'b1111_1111_1111_1111;
        end
    end

    initial
    begin
        forever
        begin
            @(force10w15);
            _10wn = 16'b0111_1111_1111_1111;
            #20
             _10wn = 16'b1111_1111_1111_1111;
        end
    end

    initial
    begin
        forever
        begin
            @(force10w10);
            _10wn = 16'b1111_1011_1111_1111;
            #20
             _10wn = 16'b1111_1111_1111_1111;
        end
    end

    initial
    begin
        forever
        begin
            @(force10w14);
            _10wn = 16'b1011_1111_1111_1111;
            #20
             _10wn = 16'b1111_1111_1111_1111;
        end
    end

    initial
    begin
        forever
        begin
            @(force10w9);
            _10wn = 16'b1111_1101_1111_1111;
            #20
             _10wn = 16'b1111_1111_1111_1111;
        end
    end

    initial
    begin
        forever
        begin
            @(force10w13);
            _10wn = 16'b1101_1111_1111_1111;
            #20
             _10wn = 16'b1111_1111_1111_1111;
        end
    end

    initial
    begin
        forever
        begin
            @(force10w8);
            _10wn = 16'b1111_1110_1111_1111;
            #20
             _10wn = 16'b1111_1111_1111_1111;
        end
    end

    initial
    begin
        forever
        begin
            @(force10w12);
            _10wn = 16'b1110_1111_1111_1111;
            #20
             _10wn = 16'b1111_1111_1111_1111;
        end
    end

    initial
    begin
        forever
        begin
            @(force10w4);
            _10wn = 16'b1111_1111_1110_1111;
            #200
             _10wn = 16'b1111_1111_1111_1111;
        end
    end

    initial
    begin
        forever
        begin
            @(force10w5);
            _10wn = 16'b1111_1111_1101_1111;
            #200
             _10wn = 16'b1111_1111_1111_1111;
        end
    end


    initial
    begin
        forever
        begin
            #200 -> force10w2;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #250 -> force10w11;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #300 -> force10w15;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #220 -> force10w10;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #320 -> force10w14;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #420 -> force10w9;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #450 -> force10w13;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #460 -> force10w12;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #480 -> force10w8;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #1500 -> force10w4;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #1000 -> force10w5;
            #10000000;
        end
    end



    initial
    begin
        clk = 1'b1;
        alu_sigma_bus = 4'b1111;
        t5n = 1'b1;
        _3wn = 8'hff;
        _10wn = 16'hffff;

        //		#10 -> pulse_3w0_low;
        //		#1 -> pulse_3w0_high;

        #30000 $finish;
    end
    always #1 clk = ~clk;
    always #1;
    always #2 alu_sigma_bus = alu_sigma_bus + 1'b1;
    always #2 -> pulse_3w0_low;
endmodule

/*****************************************************************/
/*                                                               */
/*              The main adder test                              */
/*                                                               */
/*****************************************************************/
module main_adder_test();

    reg [3:0] alpha;
    reg [3:0] beta;
    reg [44:1] En;					/* microcode command bus input */
    reg alu_clk;

    wire [3:0] alu_out_bus;
    wire [3:0] alu_out_bus_n;
    wire P2;
    wire P3;
    wire P4;

    integer i;
    integer j;

    main_adder name(
                   .alpha(alpha),
                   .beta(beta),
                   .En(En),
                   .ZPR4(1'b0),
                   .alu_clk(alu_clk),
                   .alu_out_bus(alu_out_bus),
                   .alu_out_bus_n(alu_out_bus_n),
                   .P2(P2),
                   .P3(P3),
                   .P4(P4) );

    /* clear the buses */
    task clear_bus;
        begin
            alpha = 4'b0000;
            beta = 4'b0000;
            $display("Current simulation time is: ", $time);
        end
    endtask

    /* bcd addition with P2 as carry flag */
    task __4w0d;
        input [3:0] a;
        input [3:0] b;
        integer expected;
        integer _P2;
        integer exp_sum;
        begin
            alpha = a;
            beta = b;
            En[16] = 1'b0;
            #1;
            @(posedge alu_clk)
             begin
                 expected = a + b;
                 _P2 = expected / 10;
                 exp_sum = expected % 10;
                 if ((alu_out_bus != exp_sum) || (_P2 != P2))
                 begin
                     $display("Test failed at task  __4w0d, a = %d, b = %d, alu_out_bus = %d,  exp_sum = %d", a, b, alu_out_bus, exp_sum);
                     $display("Test failed at task  __4w0d, P2 = %d, expected P2 = %d\n", P2, _P2);
                     $finish;
                 end
                 else
                 begin
                     //		$display("Test passed at task  __4w0d, a = %d, b = %d, alu_out_bus = %d,  exp_sum = %d", a, b, alu_out_bus, exp_sum);
                     //		$display("Test passed at task  __4w0d, P2 = %d, expected P2 = %d\n", P2, _P2);
                 end
             end
             En[16] = 1'b1;
        end
    endtask

    /* binary addition with P2 as carry flag */
    task __4w0;
        input [3:0] a;
        input [3:0] b;
        integer expected;
        integer _P2;
        integer exp_sum;
        begin
            alpha = a;
            beta = b;
            #1;
            @(posedge alu_clk)
             begin
                 expected = a + b;
                 _P2 = expected[4];
                 exp_sum = expected[3:0];
                 if ((alu_out_bus != exp_sum) || (_P2 != P2))
                 begin
                     $display("Test failed at task  __4w0, a = %d, b = %d, alu_out_bus = %d,  exp_sum = %d", a, b, alu_out_bus, exp_sum);
                     $display("Test failed at task  __4w0, P2 = %d, expected P2 = %d\n", P2, _P2);
                     $finish;
                 end
                 else
                 begin
                     //		$display("Test passed at task  __4w0, a = %d, b = %d, alu_out_bus = %d,  exp_sum = %d", a, b, alu_out_bus, exp_sum);
                     //		$display("Test passed at task  __4w0, P2 = %d, expected P2 = %d\n", P2, _P2);
                 end
             end
         end
     endtask

     /* binary addition a + b + 1 with P2 as carry flag */
     task __4w1;
         input [3:0] a;
         input [3:0] b;
         integer expected;
         integer _P2;
         integer exp_sum;
         begin
             alpha = a;
             beta = b;
             En[12] = 1'b0;
             #1;
             @(posedge alu_clk)
              begin
                  expected = a + b + 1;
                  _P2 = expected[4];
                  exp_sum = expected[3:0];
                  if ((alu_out_bus != exp_sum) || (_P2 != P2))
                  begin
                      $display("Test failed at task  __4w1, a = %d, b = %d, alu_out_bus = %d,  exp_sum = %d", a, b, alu_out_bus, exp_sum);
                      $display("Test failed at task  __4w1, P2 = %d, expected P2 = %d\n", P2, _P2);
                      $finish;
                  end
                  else
                  begin
                      //		$display("Test passed at task  __4w1, a = %d, b = %d, alu_out_bus = %d,  exp_sum = %d", a, b, alu_out_bus, exp_sum);
                      //		$display("Test passed at task  __4w1, P2 = %d, expected P2 = %d\n", P2, _P2);
                  end
              end
              En[12] = 1'b1;
         end
     endtask

     /* bcd addition a + b + 1 with P2 as carry flag */
     task __4w1d;
         input [3:0] a;
         input [3:0] b;
         integer expected;
         integer _P2;
         integer exp_sum;
         begin
             alpha = a;
             beta = b;
             En[12] = 1'b0;
             En[16] = 1'b0;
             #1;
             @(posedge alu_clk)
              begin
                  expected = a + b + 1;
                  _P2 = expected / 10;
                  exp_sum = expected % 10;
                  if ((alu_out_bus != exp_sum) || (_P2 != P2))
                  begin
                      $display("Test failed at task  __4w1, a = %d, b = %d, alu_out_bus = %d,  exp_sum = %d", a, b, alu_out_bus, exp_sum);
                      $display("Test failed at task  __4w1, P2 = %d, expected P2 = %d\n", P2, _P2);
                      $finish;
                  end
                  else
                  begin
                      //		$display("Test passed at task  __4w1, a = %d, b = %d, alu_out_bus = %d,  exp_sum = %d", a, b, alu_out_bus, exp_sum);
                      //		$display("Test passed at task  __4w1, P2 = %d, expected P2 = %d\n", P2, _P2);
                  end
              end
              En[12] = 1'b1;
             En[16] = 1'b1;
         end
     endtask

     /* binary addition a + b with P2 as carry flag, P3:= P2 */
     task __4w2;
         input [3:0] a;
         input [3:0] b;
         integer expected;
         integer _P2;
         integer exp_sum;
         begin
             alpha = a;
             beta = b;
             En[11] = 1'b0;
             En[4] = 1'b0;
             #1;
             En[4] = 1'b1;
             @(posedge alu_clk)
              begin

                  expected = a + b;
                  _P2 = expected[4];
                  exp_sum = expected[3:0];
                  if ((alu_out_bus != exp_sum) || (_P2 != P2) || (P3 != P2))
                  begin
                      $display("Test failed at task  __4w2, a = %d, b = %d, alu_out_bus = %d,  exp_sum = %d", a, b, alu_out_bus, exp_sum);
                      $display("Test failed at task  __4w2, P2 = %d, expected P2 = %d", P2, _P2);
                      $display("Test failed at task  __4w2, P3 = %d, expected P3 = %d\n", P3, P2);
                      $finish;
                  end
                  else
                  begin
                  end
              end
              En[11] = 1'b1;
         end
     endtask

     /* bcd addition a + b with P2 as carry flag, P3:= P2 */
     task __4w2d;
         input [3:0] a;
         input [3:0] b;
         integer expected;
         integer _P2;
         integer exp_sum;
         begin
             alpha = a;
             beta = b;
             En[11] = 1'b0;
             En[16] = 1'b0;
             En[4] = 1'b0;
             #1;
             En[4] = 1'b1;
             @(posedge alu_clk)
              begin

                  expected = a + b;
                  _P2 = expected / 10;
                  exp_sum = expected %10;
                  if ((alu_out_bus != exp_sum) || (_P2 != P2) || (P3 != P2))
                  begin
                      $display("Test failed at task  __4w2d, a = %d, b = %d, alu_out_bus = %d,  exp_sum = %d", a, b, alu_out_bus, exp_sum);
                      $display("Test failed at task  __4w2d, P2 = %d, expected P2 = %d", P2, _P2);
                      $display("Test failed at task  __4w2d, P3 = %d, expected P3 = %d\n", P3, P2);
                      $finish;
                  end
                  else
                  begin
                  end
              end
              En[11] = 1'b1;
             En[16] = 1'b1;
         end
     endtask

     /* binary addition a + b + P3 with P2 as carry flag, P3:= P2 */
     task __4w3;
         input [3:0] a;
         input [3:0] b;
         integer expected;
         integer _P2;
         integer exp_sum;
         integer oldP3;
         begin
             alpha = a;
             beta = b;
             oldP3 = P3;
             En[11] = 1'b0;
             En[12] = 1'b0;
             En[4] = 1'b0;
             #1;
             En[4] = 1'b1;
             @(posedge alu_clk)
              begin

                  expected = a + b + oldP3;
                  _P2 = expected[4];
                  exp_sum = expected[3:0];
                  if ((alu_out_bus != exp_sum) || (_P2 != P2) || (P3 != P2))
                  begin
                      $display("Test failed at task  __4w3, a = %d, b = %d, alu_out_bus = %d,  exp_sum = %d", a, b, alu_out_bus, exp_sum);
                      $display("Test failed at task  __4w3, P2 = %d, expected P2 = %d", P2, _P2);
                      $display("Test failed at task  __4w3, P3 = %d, expected P3 = %d\n", P3, P2);
                      $finish;
                  end
                  else
                  begin
                  end
              end
              En[11] = 1'b1;
             En[12] = 1'b1;
         end
     endtask

     /* bcd addition a + b + P3 with P2 as carry flag, P3:= P2 */
     task __4w3d;
         input [3:0] a;
         input [3:0] b;
         integer expected;
         integer _P2;
         integer exp_sum;
         integer oldP3;
         begin
             alpha = a;
             beta = b;
             oldP3 = P3;
             En[11] = 1'b0;
             En[12] = 1'b0;
             En[16] = 1'b0;
             En[4] = 1'b0;
             #1;
             En[4] = 1'b1;
             @(posedge alu_clk)
              begin

                  expected = a + b + oldP3;
                  _P2 = expected / 10;
                  exp_sum = expected % 10;
                  if ((alu_out_bus != exp_sum) || (_P2 != P2) || (P3 != P2))
                  begin
                      $display("Test failed at task  __4w3d, a = %d, b = %d, alu_out_bus = %d,  exp_sum = %d", a, b, alu_out_bus, exp_sum);
                      $display("Test failed at task  __4w3d, P2 = %d, expected P2 = %d", P2, _P2);
                      $display("Test failed at task  __4w3d, P3 = %d, expected P3 = %d\n", P3, P2);
                      $finish;
                  end
                  else
                  begin
                  end
              end
              En[11] = 1'b1;
             En[12] = 1'b1;
             En[16] = 1'b1;
         end
     endtask

     /* binary addition a + b + 1 with P2 as carry flag, P3:= P2 */
     task __4w4;
         input [3:0] a;
         input [3:0] b;
         integer expected;
         integer _P2;
         integer exp_sum;
         begin
             alpha = a;
             beta = b;
             En[10] = 1'b0;
             En[4] = 1'b0;
             #1;
             En[4] = 1'b1;
             @(posedge alu_clk)
              begin

                  expected = a + b + 1;
                  _P2 = expected[4];
                  exp_sum = expected[3:0];
                  if ((alu_out_bus != exp_sum) || (_P2 != P2) || (P3 != P2))
                  begin
                      $display("Test failed at task  __4w4, a = %d, b = %d, alu_out_bus = %d,  exp_sum = %d", a, b, alu_out_bus, exp_sum);
                      $display("Test failed at task  __4w4, P2 = %d, expected P2 = %d", P2, _P2);
                      $display("Test failed at task  __4w4, P3 = %d, expected P3 = %d\n", P3, P2);
                      $finish;
                  end
                  else
                  begin
                  end
              end
              En[10] = 1'b1;
         end
     endtask

     /* bcd addition a + b + 1 with P2 as carry flag, P3:= P2 */
     task __4w4d;
         input [3:0] a;
         input [3:0] b;
         integer expected;
         integer _P2;
         integer exp_sum;
         begin
             alpha = a;
             beta = b;
             En[10] = 1'b0;
             En[16] = 1'b0;
             En[4] = 1'b0;
             #1;
             En[4] = 1'b1;
             @(posedge alu_clk)
              begin

                  expected = a + b + 1;
                  _P2 = expected / 10;
                  exp_sum = expected %10;
                  if ((alu_out_bus != exp_sum) || (_P2 != P2) || (P3 != P2))
                  begin
                      $display("Test failed at task  __4w4d, a = %d, b = %d, alu_out_bus = %d,  exp_sum = %d", a, b, alu_out_bus, exp_sum);
                      $display("Test failed at task  __4w4d, P2 = %d, expected P2 = %d", P2, _P2);
                      $display("Test failed at task  __4w4d, P3 = %d, expected P3 = %d\n", P3, P2);
                      $finish;
                  end
                  else
                  begin
                  end
              end
              En[10] = 1'b1;
             En[16] = 1'b1;
         end
     endtask

     /* 4w5 */
     task _4w5;
         input [3:0] a;
         input [3:0] b;
         integer expected;
         begin
             alpha = a;
             beta = b;
             En[10] = 1'b0;
             En[12] = 1'b0;
             #1;
             @(posedge alu_clk)
              begin
                  expected = (a & b);
                  if (alu_out_bus != expected)
                  begin
                      $display("Test failed at task  __4w5, a = %d, b = %d, alu_out_bus = %d,  expected = %d", a, b, alu_out_bus, expected);
                      #4;
                      $finish;
                  end
                  else
                  begin
                  end
              end
              En[10] = 1'b1;
             En[12] = 1'b1;
         end
     endtask

     /* 4w6 */
     task _4w6;
         input [3:0] a;
         input [3:0] b;
         integer expected;
         begin
             alpha = a;
             beta = b;
             En[10] = 1'b0;
             En[11] = 1'b0;
             #1;
             @(posedge alu_clk)
              begin
                  expected = (a ^ b);
                  if (alu_out_bus != expected)
                  begin
                      $display("Test failed at task  __4w6, a = %d, b = %d, alu_out_bus = %d,  expected = %d", a, b, alu_out_bus, expected);
                      $finish;
                  end
                  else
                  begin
                  end
              end
              En[10] = 1'b1;
             En[11] = 1'b1;
         end
     endtask

     /* 4w7 */
     task _4w7;
         input [3:0] a;
         input [3:0] b;
         integer expected;
         integer oldP3;
         integer newP3;
         begin
             oldP3 = P3;
             alpha = a;
             beta = b;
             En[10] = 1'b0;
             En[11] = 1'b0;
             En[12] = 1'b0;
             En[4] = 1'b0;
             #1;
             En[4] = 1'b1;

             @(posedge alu_clk)
              begin
                  expected = ((a + b) >> 1) | (oldP3 << 3);
                  newP3 = (a + b) & 1;

                  if ((alu_out_bus != expected) || (P3 != newP3))
                  begin
                      $display("Test failed at task  __4w7, a = %d, b = %d, alu_out_bus = %d,  expected = %d", a, b, alu_out_bus, expected);
                      $display("Test failed at task  __4w7, P3 = %d, expected P3 = %d\n", P3, P2);
                      $finish;
                  end
                  else
                  begin
                  end
              end
              En[10] = 1'b1;
             En[11] = 1'b1;
             En[12] = 1'b1;
         end
     endtask

     event simple_add_bin;
    event simple_add_dec; // with the bcd corrector
    event a_add_b_add_1_bin;	// 4w1
    event a_add_b_add_1_dec;	// 4w1d
    event __4w2_bin;
    event __4w2_dec;
    event __4w3_bin;
    event __4w3_dec;

    event __4w4_bin;
    event __4w4_dec;

    event __4w5;
    event __4w6;
    event __4w7;


    /* a + b binary */
    initial
    begin
        forever
        begin
            @(simple_add_bin);
            for (i = 0; i < 16; i = i + 1)
            begin
                for (j = 0; j < 16; j = j + 1)
                begin
                    __4w0(i, j);
                    #1;
                end
            end
            clear_bus();
        end
    end


    /* a + b bcd */
    initial
    begin
        forever
        begin
            @(simple_add_dec);
            for (i = 0; i < 10; i = i + 1)
            begin
                for (j = 0; j < 10; j = j + 1)
                begin
                    __4w0d(i, j);
                    #1;
                end
            end
            clear_bus();
        end
    end

    /* a + b + 1 binary */
    initial
    begin
        forever
        begin
            @(a_add_b_add_1_bin);
            for (i = 0; i < 16; i = i + 1)
            begin
                for (j = 0; j < 16; j = j + 1)
                begin
                    __4w1(i, j);
                    #1;
                end
            end
            clear_bus();
        end
    end


    /* a + b + 1  bcd */
    initial
    begin
        forever
        begin
            @(a_add_b_add_1_dec);
            for (i = 0; i < 10; i = i + 1)
            begin
                for (j = 0; j < 10; j = j + 1)
                begin
                    __4w1d(i, j);
                    #1;
                end
            end
            clear_bus();
        end
    end

    /* 4w2  binary */
    initial
    begin
        forever
        begin
            @(__4w2_bin);
            for (i = 0; i < 16; i = i + 1)
            begin
                for (j = 0; j < 16; j = j + 1)
                begin
                    __4w2(i, j);
                    #1;
                    __4w2(0, 0);
                    #1;
                end
            end
            clear_bus();
        end
    end

    /* 4w2  bcd */
    initial
    begin
        forever
        begin
            @(__4w2_dec);
            for (i = 0; i < 10; i = i + 1)
            begin
                for (j = 0; j < 10; j = j + 1)
                begin
                    __4w2d(i, j);
                    #1;
                    __4w2d(0, 0);
                    #1;
                end
            end
            clear_bus();
        end
    end

    /* 4w3 bin a + b + P3, P3 := P2 */
    initial
    begin
        forever
        begin
            @(__4w3_bin);
            for (i = 0; i < 16; i = i + 1)
            begin
                for (j = 0; j < 16; j = j + 1)
                begin
                    __4w3(15, 1);
                    #1;
                    __4w3(i, j);
                    #1;
                    __4w3(0, 0);
                    #1;
                end
            end
            clear_bus();
        end
    end


    /* 4w3 bcd a + b + P3, P3 := P2 */
    initial
    begin
        forever
        begin
            @(__4w3_dec);
            for (i = 0; i < 10; i = i + 1)
            begin
                for (j = 0; j < 10; j = j + 1)
                begin
                    __4w3d(9, 1);
                    #1;
                    __4w3d(i, j);
                    #1;
                    __4w3d(0, 0);
                    #1;
                end
            end
            clear_bus();
        end
    end

    /* 4w4  binary */
    initial
    begin
        forever
        begin
            @(__4w4_bin);
            for (i = 0; i < 16; i = i + 1)
            begin
                for (j = 0; j < 16; j = j + 1)
                begin
                    __4w4(i, j);
                    #1;
                    __4w2(0, 0);
                    #1;
                end
            end
            clear_bus();
        end
    end

    /* 4w4  bcd */
    initial
    begin
        forever
        begin
            @(__4w4_dec);
            for (i = 0; i < 10; i = i + 1)
            begin
                for (j = 0; j < 10; j = j + 1)
                begin
                    __4w4d(i, j);
                    #1;
                    __4w4d(0, 0);
                    #1;
                end
            end
            clear_bus();
        end
    end

    /* 4w5 */
    initial
    begin
        forever
        begin
            @(__4w5);
            for (i = 0; i < 16; i = i + 1)
            begin
                for (j = 0; j < 16; j = j + 1)
                begin
                    _4w5(i, j);
                    #1;
                end
            end
            clear_bus();
        end
    end

    /* 4w6 */
    initial
    begin
        forever
        begin
            @(__4w6);
            for (i = 0; i < 16; i = i + 1)
            begin
                for (j = 0; j < 16; j = j + 1)
                begin
                    _4w6(i, j);
                    #1;
                end
            end
            clear_bus();
        end
    end

    /* 4w7 */
    initial
    begin
        forever
        begin
            @(__4w7);
            for (i = 0; i < 16; i = i + 1)
            begin
                _4w7(i, 4'b0000);
                #1;
            end
            clear_bus();
        end
    end


    /* ------------------------------------------- */
    initial
    begin
        forever
        begin
            #16 -> simple_add_bin;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #2000 -> simple_add_dec;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #3000 -> a_add_b_add_1_bin;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #4100 -> a_add_b_add_1_dec;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #4500 -> __4w2_bin;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #6700 -> __4w2_dec;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #7600 -> __4w3_bin;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #11000 -> __4w3_dec;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #12400 -> __4w4_bin;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #15000 -> __4w4_dec;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #16000 -> __4w5;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #17200 -> __4w6;
            #10000000;
        end
    end

    initial
    begin
        forever
        begin
            #19000 -> __4w7;
            #10000000;
        end
    end


    /* main event loop */
    initial
    begin
        alu_clk = 1'b0;
        alpha = 4'b0000;
        beta = 4'b0000;
        En = 48'hffff_ffff_ffff;

        #30000 $finish;
    end
    always #1 alu_clk = ~alu_clk;

endmodule

/** metastability tests **/
module meta_test();

    reg [7:0] in;
    wire [7:0] out;
    reg clk;

    xclockd DUT(.in(in), .out(out), .clk(clk));

    initial
    begin
        clk = 1'b0;
        in = 8'h0;
        #300 $finish;
    end

    initial
    begin
        # 21 in[1] = 1'b1;
        # 2 in[1] = 1'b0;
    end

    initial
    begin
        # 31 in[3] = 1'b1;
        # 10 in[3] = 1'b0;
    end

    initial
    begin
        # 49 in[7] = 1'b1;
        # 10 in[7] = 1'b0;
    end


    always #10 clk = ~clk;


endmodule



