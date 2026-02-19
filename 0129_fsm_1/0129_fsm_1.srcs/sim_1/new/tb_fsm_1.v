`timescale 1ns / 1ps

module tb_fsm_1 ();

    reg clk;
    reg reset;
    reg [2:0] sw;
    wire [2:0] led;

    fsm_1 cut (

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
        sw = 3'b000;

        #10;
        reset = 0;

        #10;
        sw = 3'b001; // s1

        #10;
        sw = 3'b010; //s2

        #10;
        sw = 3'b100;  //s3

        #10;
        sw = 3'b011;  //s1

        #10;
        sw = 3'b010;  //s2

        #10;
        sw = 3'b100;  //s3

        #10;
        sw = 3'b000;  //s0

        #10;
        sw = 3'b010;  //s2

        #10;
        sw = 3'b100;  //s3

        #10;
        sw = 3'b111;  //s4

        #10;
        sw = 3'b000;  //s0

        #10;
        $stop;

    end

endmodule
