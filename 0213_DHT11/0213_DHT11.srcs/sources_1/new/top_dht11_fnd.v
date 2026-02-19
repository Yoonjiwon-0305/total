`timescale 1ns / 1ps

module top_dht11_fnd (
    input        clk,
    input        reset,
    input        btn_r,
    input        sw,
    inout        dhtio,
    output [4:0] debug,
    output [7:0] fnd_data,
    output [3:0] fnd_digit
);

    wire w_btn_tick;
    wire [27:0] w_dht_data;

    
    btn_debounce U_BTN_DEBOUNCE (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_r),
        .o_btn(w_btn_tick)
    );

    dht11_controller U_DHT11 (
        .clk(clk),
        .reset(reset),
        .start(w_btn_tick),
        .dht_data(w_dht_data),
        .dht11_done(),
        .dht11_valid(),
        .debug(debug),
        .dhtio(dhtio)
    );

    fnd_controller U_FND_CTRL (
        .clk(clk),
        .reset(reset),
        .sel_display(sw),
        .fnd_in_data(w_dht_data),
        .fnd_digit(fnd_digit),
        .fnd_data(fnd_data)
    );
endmodule
