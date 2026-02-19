`timescale 1ns / 1ps


module tb_ascii_decorder();

    reg clk,reset;
    reg [7:0] uart_data ;
    reg uart_done;
    wire [7;0] uart_mode;

    ascii_decorder dut(

        .clk(clk),
        .reset(reset),
        .uart_data(uart_data),
        .uart_done(uart_done),
        .uart_mode(uart_mode)

);
endmodule
