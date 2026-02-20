`timescale 1ns / 1ps

module total_toggle_or_gate (

    input  [7:0] uart_mode,
    input        btn_r,
    input        btn_l,
    input        btn_u,
    input        btn_d,
    input  [2:0] sw,
    output [6:0] o_mode
);

    assign o_mode ={w_o_mode_2,w_o_mode_1,w_o_mode_0,w_o_mode_d,w_o_mode_u,w_o_mode_l,w_o_mode_r};

    wire w_o_mode_2,w_o_mode_1,w_o_mode_0,w_o_mode_d,w_o_mode_u,w_o_mode_l,w_o_mode_r;
    
    wire w_uart_0, w_uart_1, w_uart_2;

    sw_toggle SW_TO_0 (
        .clk  (clk),
        .reset(reset),
        .tick (uart_mode[5]),
        .state(w_uart_0)
    );

    sw_toggle SW_TO_1 (
        .clk  (clk),
        .reset(reset),
        .tick (uart_mode[6]),
        .state(w_uart_1)
    );

    sw_toggle SW_TO_2 (
        .clk  (clk),
        .reset(reset),
        .tick (uart_mode[7]),
        .state(w_uart_2)
    );

    or_gate U_OR_R (
        .uart_mode  (uart_mode[0]),
        .orig_mode  (btn_r),
        .select_mode(w_o_mode_r)

    );

    or_gate U_OR_L (
        .uart_mode  (uart_mode[1]),
        .orig_mode  (btn_l),
        .select_mode(w_o_mode_l)

    );

    or_gate U_OR_U (
        .uart_mode  (uart_mode[2]),
        .orig_mode  (btn_u),
        .select_mode(w_o_mode_u)

    );

    or_gate U_OR_D (
        .uart_mode  (uart_mode[3]),
        .orig_mode  (btn_d),
        .select_mode(w_o_mode_d)

    );

    or_gate U_OR_0 (
        .uart_mode  (w_uart_0),
        .orig_mode  (sw[0]),
        .select_mode(w_o_mode_0)

    );

    or_gate U_OR_1 (
        .uart_mode  (w_uart_1),
        .orig_mode  (sw[1]),
        .select_mode(w_o_mode_1)

    );

    or_gate U_OR_2 (
        .uart_mode  (w_uart_2),
        .orig_mode  (sw[2]),
        .select_mode(w_o_mode_2)

    );



endmodule

module or_gate (
    input  uart_mode,
    input  orig_mode,
    output select_mode

);

    assign select_mode = uart_mode | orig_mode;

endmodule

