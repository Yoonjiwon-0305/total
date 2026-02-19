`timescale 1ns / 1ps


module tb_counter ();

    reg clk, reset;
    reg [7:0] a, b;
    wire [7:0] fnd_data;
    wire [3:0] fnd_digit;
    wire c;

    top_adder dut (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .fnd_digit(fnd_digit),
        .fnd_data(fnd_data),
        .c(c)

    );

    always #5 clk = ~clk;  // 5 나노마다 clk출력


    initial begin

        #0;
        clk = 0;
        reset = 1;
        a = 0;  
        b = 0;  

        #20;
        clk=0;
        reset =0;
        a=1;
        b=5;

        #20;
        clk=0;
        reset =0;
        a=10;
        b=20;

        #20;
        clk=0;
        reset =0;
        a=100;
        b=500;

        #20;
        clk=0;
        reset =0;
        a=255;
        b=255;
        

    end


endmodule
