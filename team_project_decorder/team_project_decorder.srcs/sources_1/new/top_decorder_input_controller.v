`timescale 1ns / 1ps

module top_decorder_input_controller (

    input       clk,
    input       reset,
    input       btn_r,
    input       btn_l,
    input       btn_u,
    input       btn_d,
    input [2:0] sw,
    input [7:0] uart_data,
    input       uart_done,

    output o_btn_r,
    output o_btn_l,
    output o_btn_u,
    output o_btn_d,
    output o_sw_0,
    output o_sw_1,
    output o_sw_2
);
    wire w_uart_mode;
    wire w_btn_r, w_btn_l, w_btn_u, w_btn_d, w_uart_0, w_uart_1, w_uart_2;
    wire [6:0] w_select_mode;

    ascii_decorder U_ASCII_DECO (

        .clk      (clk),
        .reset    (reset),
        .uart_data(uart_data),
        .uart_done(uart_done),
        .uart_mode(w_uart_mode)
    );

    btn_debounce U_BTN_R (

        .clk  (clk),
        .reset(reset),
        .i_btn(btn_r),
        .o_btn(w_btn_r)
    );

    btn_debounce U_BTN_L (

        .clk  (clk),
        .reset(reset),
        .i_btn(btn_l),
        .o_btn(w_btn_l)
    );

    btn_debounce U_BTN_U (

        .clk  (clk),
        .reset(reset),
        .i_btn(btn_u),
        .o_btn(w_btn_u)
    );

    btn_debounce U_BTN_D (

        .clk  (clk),
        .reset(reset),
        .i_btn(btn_d),
        .o_btn(w_btn_d)
    );

    total_toggle_or_gate U_OR_TOGGLE (

        .uart_mode(w_uart_mode),
        .btn_r(w_btn_r),
        .btn_l(w_btn_l),
        .btn_u(w_btn_u),
        .btn_d(w_btn_d),
        .sw(sw),
        .o_mode(w_select_mode)
    );

    priority_controller U_INPUT_CONTROLLER(
        .clk(clk),
        .reset(reset),
        .i_sw(w_select_mode[6:4]),
        .i_btn_r(w_select_mode[0]),
        .i_btn_l(w_select_mode[1]),
        .i_btn_u(w_select_mode[2]),
        .i_btn_d(w_select_mode[3]),
        .o_btn_r(o_btn_r),
        .o_btn_l(o_btn_l),
        .o_btn_u(o_btn_u),
        .o_btn_d(o_btn_d),
        .o_sw_0(o_sw_0),
        .o_sw_1(o_sw_1),
        .o_sw_2(o_sw_2)
);

endmodule
