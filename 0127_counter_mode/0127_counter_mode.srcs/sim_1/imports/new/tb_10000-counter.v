`timescale 1ns / 1ps

module tb_10000_counter ();


    //wire [7:0] fnd_data;
    //wire [3:0] fnd_digit;


    /*top_10000_counter dut (
    .clk(clk),
    .reset(reset),
    .fnd_digit(fnd_digit),
    .fnd_data(fnd_data)


);  */


    reg clk, reset;
    reg [2:0] sw;
    reg  i_tick;
    wire [13:0] counter;

   

    counter_14 dut (
        .clk(clk),
        .reset(reset),
        .mode(sw[0]),
        .clear(sw[2]),
        .run_stop(sw[1]),
        .i_tick(i_tick),
        .counter(counter)

    );

    always #5 clk = ~clk;

    always #10 i_tick = ~i_tick; // 임의로 설정한 tick

    initial begin
        #0;
        clk = 0;
        reset = 1;
        sw[0] = 0;
        sw[1] = 0;
        sw[2] = 0;
        i_tick = 1;

        #200000; //200_000n(나노) hz 주기
        reset = 0;
        sw[0] = 0;
        sw[1] = 1;
        sw[2] = 0;

        #200000;        
        sw[0] = 1;
        sw[1] = 0;
        sw[2] = 0;

        #200000;        
        sw[0] = 1;
        sw[1] = 1;
        sw[2] = 0;

        #200000;        
        sw[0] = 1;
        sw[1] = 1;
        sw[2] = 1;



        #200000;
        $stop;


    end


endmodule
