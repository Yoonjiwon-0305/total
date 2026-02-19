`timescale 1ns / 1ps

module tb_fsm_mealy(   );

    reg clk;
    reg reset;
    reg din_bit;
    wire dout_bit;


    fsm_mealy_01 dut (

    .clk(clk),
    .reset(reset),
    .din_bit(din_bit),
    .dout_bit(dout_bit)
);

    always #10 clk= ~clk;

    initial begin
        #0;
        clk=0;
        reset=1;
        din_bit=0; //0

        /*#20;
        reset=0;
        din_bit=0; //0*/

        #20;
        reset=0;
        din_bit=1; //1

        #20;
        din_bit=0; //0

        #20;
        din_bit=1; //1

        #20;
        din_bit=1; //1

        #20;
        din_bit=0; //0

        #20;
        din_bit=0; //0

        #20;
        din_bit=1; //1

        #20;
        din_bit=0; //0

        #20;
        din_bit=0; //0

        #20;
        din_bit=1; //1

        #20;
        din_bit=1; //1

        #20;
        din_bit=0; //0

        #20;
        din_bit=1; //1

        #20;
        din_bit=1; //1

        #20;
        din_bit=0; //0

        #20;
        $stop;

    end


endmodule
