`timescale 1ns / 1ps


module tb_uart_tx ();


    reg  clk;
    reg  reset;
    reg  btn_down;  // 100msec 만큼 필요
    wire uart_tx;

    uart_top dut (
        .clk(clk),
        .reset(reset),
        .btn_down(btn_down),
        .uart_tx(uart_tx)
    );

    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        reset = 1;
        btn_down = 0;

        #20;
        reset = 0;
        btn_down = 1'b1;

        #100_000_000;//100usec
        btn_down = 1'b0;

        $stop;



    end
endmodule
