`timescale 1ns / 1ps

module tb_stopwatch_watch ();

    reg clk;
    reg reset;
    reg btn_r;  //i_run_stop
    reg btn_l;  //i_clear
    reg btn_low;
    reg btn_high;
    reg [3:0] sw;  //sw[0] up/down
    wire [3:0] fnd_digit;
    wire [7:0] fnd_data;

    top_stopwatch_watch dut (

        .clk      (clk),
        .reset    (reset),
        .btn_r    (btn_r),      //i_run_stop
        .btn_l    (btn_l),      //i_clear
        .btn_low  (btn_low),
        .btn_high (btn_high),
        .sw       (sw),         //sw[0] up/down
        .fnd_digit(fnd_digit),
        .fnd_data (fnd_data)

    );



    always #5 clk = ~clk;

    //1msec=10_000_000
    //1sec=1000_000_000
    initial begin
        // 초기화
        #0;
        clk = 0;
        reset = 1;
        btn_r = 0;
        btn_l = 0;
        btn_low = 0;
        btn_high = 0;
        sw = 4'b0000;

        #10_000_000; 
        reset = 0;
        btn_r = 0;
        btn_l = 0;
        btn_low = 0;
        btn_high = 0;
        sw = 4'b0000;

        #10_000_000; 
        btn_r = 1;
        btn_l = 0;
        btn_low = 0;
        btn_high = 0;
        sw = 4'b0000;

        #1000_000_000; 
        btn_r = 1;
        btn_l = 0;
        btn_low = 0;
        btn_high = 0;
        sw = 4'b0000;

        #100_000_000; 
        btn_r = 0; 
        btn_l = 1; 
        btn_low = 0;
        btn_high = 0;
        sw = 4'b0000;

        #50_000_000; 
        btn_r = 1;
        btn_l = 0;
        btn_low = 0;
        btn_high = 0;
        sw = 4'b0001;

        #600_000_000; 
        btn_r = 0;
        btn_l = 1;
        btn_low = 0;
        btn_high = 0;
        sw = 4'b0001;

        #800_000_000; 
        btn_r = 1; 
        btn_l = 0; 
        btn_low = 0;
        btn_high = 0;
        sw = 4'b0000; 

        #50_000_000; 
        btn_r = 0; 
        btn_l = 1; 
        btn_low = 0;
        btn_high = 0;
        sw = 4'b0000; 

        #100_000_000; 
        btn_r = 0; 
        btn_l = 0;
        btn_low = 0;
        btn_high = 0;
        sw = 4'b0010; 

        #300_000_000; 
        btn_r = 0;
        btn_l = 0;
        btn_low = 1;
        btn_high = 0;
        sw = 4'b0000; 

        #800_000_000;
        btn_r = 0;
        btn_l = 0;
        btn_low = 0;
        btn_high = 1;
        sw = 4'b0100; 

        #600_000_000; 
        btn_r = 0;
        btn_l = 0;
        btn_low = 0;
        btn_high = 1;
        sw = 4'b0100; 

        #100_000_000;
        btn_r = 1;
        btn_l = 0;
        btn_low = 0;
        btn_high = 0;
        sw = 4'b0100;

        #1000_000_000; 
        btn_l = 0;
        btn_low = 0;
        btn_high = 0;
        sw = 4'b0100;

        #10_000_000; 
        $stop;


    end

endmodule
