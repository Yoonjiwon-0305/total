`timescale 1ns / 1ps


module tb_fsm_moore ();

    reg  clk;
    reg  reset;
    reg  sw;
    wire led;

    fsm_moore dut (

        .clk(clk),
        .reset(reset),
        .sw(sw),
        .led(led)

    );

    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        reset = 1;
        sw = 0; 

        #10;
        reset = 0;
        sw = 0; 

        #10;
        sw = 1;

        #10;
        sw = 1;

        #10;
        sw = 0;


        #10 $stop;

    end

endmodule
