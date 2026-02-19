`timescale 1ns / 1ps

module tb_sr04 ();

    reg        clk;
    reg        reset;
    reg        echo;
    reg        start;
    wire       trigger;
    wire [8:0] distance;


    top_sr04 U_SR04 (

        .clk(clk),
        .reset(reset),
        .echo(echo),
        .start(start),
        .trigger(trigger),
        .distance(distance)
    );

    always #5 clk = ~clk;

    initial begin

        clk   = 0;
        reset = 1;
        echo  = 0;
        start = 0;

        #1000;
        reset = 0;

        #1000;
        start = 1;
        #10;
        start = 0;

        #10;
        echo = 1;

        #5_800_000;//100cm
        echo = 0;

        #100000;
        echo = 0;

        #1000;
        start = 1;
        #10;
        start = 0;

        #10;
        echo = 1;

        #26_100_000;//450cm
        echo = 0;

         #1000;
        start = 1;
        #10;
        start = 0;

        #10;
        echo = 1;

        #232_000;// 4cm
        echo = 0;

        #100000;
        echo = 0;

        #100000;
        echo = 0;
        #10000;
        $stop;

    end



endmodule


