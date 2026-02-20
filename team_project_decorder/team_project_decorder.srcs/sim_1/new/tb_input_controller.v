`timescale 1ns / 1ps

module tb_input_controller ();

    reg        clk;
    reg        reset;
    reg        btn_r;
    reg        btn_l;
    reg        btn_u;
    reg        btn_d;
    reg  [2:0] sw;
    reg  [7:0] uart_data;
    reg        uart_done;

    wire       o_btn_r;
    wire       o_btn_l;
    wire       o_btn_u;
    wire       o_btn_d;
    wire       o_sw_0;
    wire       o_sw_1;
    wire       o_sw_2;

    top_decorder_input_controller dut (

        .clk(clk),
        .reset(reset),
        .btn_r(btn_r),
        .btn_l(btn_l),
        .btn_u(btn_u),
        .btn_d(btn_d),
        .sw(sw),
        .uart_data(uart_data),
        .uart_done(uart_done),

        .o_btn_r(o_btn_r),
        .o_btn_l(o_btn_l),
        .o_btn_u(o_btn_u),
        .o_btn_d(o_btn_d),
        .o_sw_0 (o_sw_0),
        .o_sw_1 (o_sw_1),
        .o_sw_2 (o_sw_2)

    );

    always #5 clk = ~clk;

    initial begin
        #0;
        clk       = 0;
        reset     = 0;
        btn_r     = 0;
        btn_l     = 0;
        btn_u     = 0;
        btn_d     = 0;
        sw        = 3'b000;
        uart_data = 8'b00000000;
        uart_done = 0;

        #10;
        reset = 1;

        #10;
        sw = 3'b100;
        btn_r = 1;
        uart_data = 8'b01000000;
        uart_done = 1;

        #100;
        sw = 3'b010;
        btn_l = 1;
        uart_data = 8'b00100000;
        uart_done = 1;

        #100;
        sw = 3'b001;
        btn_u = 1;
        uart_data = 8'b00010000;
        uart_done = 1;

        #100;
        sw = 3'b000;
        btn_r = 1;
        btn_l = 1;
        uart_data = 8'b01100000;
        uart_done = 1;

        #100;
        sw = 3'b000;
        btn_d = 1;
        btn_u = 1;
        uart_data = 8'b00001100;
    end
endmodule
