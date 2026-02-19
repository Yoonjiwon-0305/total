`timescale 1ns / 1ps

module top_stopwatch_watch (

    input clk,
    input reset,
    input [2:0] sw,
    input btn_r,
    input btn_l,
    input uart_rx,
    output [3:0] fnd_digit,
    output [7:0] fnd_data

);

    wire [7:0] w_uart_data, w_dec_mode;
    wire w_uart_done;
    wire w_tick_100hz;
    wire w_run_stop, w_clear, w_mode;
    wire o_btn_run_stop, o_btn_clear;
    wire [23:0] w_stopwatch_time;// msec,sec,min,hour 를 한꺼번에 묶어서 보내기 위한 wire

    uart_top U_UART_TOP (
        .clk(clk),
        .reset(reset),
        .uart_rx(uart_rx),
        .uart_data(w_uart_data),
        .uart_done(w_uart_done)

    );

    ascii_decorder U_ASCII_DEC (

        .clk(clk),
        .reset(reset),
        .uart_data(w_uart_data),
        .uart_done(w_uart_done),
        .uart_mode(w_dec_mode)

    );

    or_gate U_RUN_STOP_OR (
        .uart_mode(w_dec_mode[0]),
        .orig_mode(),
        .select_mode()

    );
    or_gate U_CLEAR_OR (
        .uart_mode(w_dec_mode[1]),
        .orig_mode(),
        .select_mode()

    );
    or_gate U_SEC_UP_OR (
        .uart_mode(w_dec_mode[2]),
        .orig_mode(),
        .select_mode()

    );
    or_gate U_MIN_UP_OR (
        .uart_mode(w_dec_mode[3]),
        .orig_mode(),
        .select_mode()

    );
    or_gate U_UP_DOWN_OR (
        .uart_mode(w_dec_mode[4]),
        .orig_mode(),
        .select_mode()

    );
    or_gate U_ST_W_OR (
        .uart_mode(w_dec_mode[5]),
        .orig_mode(),
        .select_mode()

    );
    or_gate U_MODE_OR (
        .uart_mode(w_dec_mode[6]),
        .orig_mode(),
        .select_mode()

    );
    or_gate U_HOUR_UP_OR (
        .uart_mode(w_dec_mode[7]),
        .orig_mode(),
        .select_mode()

    );


    btn_debounce U_BD_RUN_STOP (

        .clk  (clk),
        .reset(reset),
        .i_btn(btn_r),
        .o_btn(o_btn_run_stop)

    );

    btn_debounce U_BD_CLEAR (

        .clk  (clk),
        .reset(reset),
        .i_btn(btn_l),
        .o_btn(o_btn_clear)

    );

    control_unit U_CONTROL_UNIT (

        .clk(clk),
        .reset(reset),
        .i_mode(sw[0]),
        .i_run_stop(o_btn_run_stop),
        .i_clear(o_btn_clear),
        .o_mode(w_mode),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear)

    );

    stopwatch_datapath U_STOPWATCH_DATAPATH (
        .clk(clk),
        .reset(reset),
        .mode(w_mode),
        .clear(w_clear),
        .run_stop(w_run_stop),
        .msec(w_stopwatch_time[6:0]),  //7bit// 다 묶어서 보냄
        .sec(w_stopwatch_time[12:7]),  //6bit
        .min(w_stopwatch_time[18:13]),  //6bit
        .hour(w_stopwatch_time[23:19])  //6bit

    );

    fnd_controller U_FND_CNRL (
        .clk(clk),
        .reset(reset),
        .sel_display(sw[2]),
        .fnd_in_data(w_stopwatch_time),
        .fnd_digit(fnd_digit),
        .fnd_data(fnd_data)

    );

endmodule
module tick_counter #(
    parameter BIT_WIDTH = 7,
    TIMES = 100
) (
    input clk,
    input reset,
    input i_tick,
    input mode,
    input clear,
    input run_stop,
    output [BIT_WIDTH-1:0] o_counter,
    output reg o_tick
);

    // counter reg 필요
    reg [BIT_WIDTH-1:0] counter_reg, counter_next;

    //assign o_count=counter_reg;

    // feedback 구조
    // State reg 
    always @(posedge clk, posedge reset) begin

        if (reset || clear) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end
    //CL
    always @(*) begin
        counter_next = counter_reg;
        o_tick = 1'b0;
        if (i_tick && run_stop) begin
            if (mode == 1'b1) begin
                //down
                if (counter_reg == 0) begin
                    counter_next = TIMES - 1;
                    o_tick = 1'b1;
                end
            end else begin
                //up
                if (counter_reg == (TIMES - 1)) begin
                    counter_next = 0;
                    o_tick = 1'b1;
                end else begin
                    counter_next = counter_reg + 1;
                    o_tick = 1'b0;
                end
            end
        end
    end
endmodule

module stopwatch_datapath (
    input clk,
    input reset,
    input mode,
    input clear,
    input run_stop,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour

);

    wire w_tick_100hz;
    wire w_sec_tick, w_min_tick, w_hour_tick;


    tick_gen_100hz U_TICK_GEN_100hz (
        .clk         (clk),
        .reset       (reset),
        .i_run_stop  (run_stop),
        .o_tick_100hz(w_tick_100hz)
    );
    tick_counter U_MSEC_COUNTER (
        .clk      (clk),
        .reset    (reset),
        .i_tick   (w_tick_100hz),
        .mode     (mode),
        .clear    (clear),
        .run_stop (run_stop),
        .o_counter(msec),
        .o_tick   (w_sec_tick)
    );
    tick_counter #(
        .BIT_WIDTH(6),
        .TIMES(60)
    ) U_SEC_COUNTER (
        .clk      (clk),
        .reset    (reset),
        .i_tick   (w_sec_tick),
        .mode     (mode),
        .clear    (clear),
        .run_stop (run_stop),
        .o_counter(sec),
        .o_tick   (w_min_tick)
    );
    //tick_min
    tick_counter #(
        .BIT_WIDTH(6),
        .TIMES(60)
    ) U_MIN_COUNTER (
        .clk      (clk),
        .reset    (reset),
        .i_tick   (w_min_tick),
        .mode     (mode),
        .clear    (clear),
        .run_stop (run_stop),
        .o_counter(min),
        .o_tick   (w_hour_tick)
    );
    //tick_hour
    tick_counter #(
        .BIT_WIDTH(5),
        .TIMES(24)
    ) U_HOUR_COUNTER (
        .clk      (clk),
        .reset    (reset),
        .i_tick   (w_hour_tick),
        .mode     (mode),
        .clear    (clear),
        .run_stop (run_stop),
        .o_counter(hour),
        .o_tick   ()
    );




endmodule



module tick_gen_100hz (
    input clk,
    input reset,
    input i_run_stop,
    output reg o_tick_100hz
);

    parameter F_COUNT = 100_000_000 / 100_000;
    reg [$clog2(F_COUNT)-1:0] r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            o_tick_100hz <= 1'b0;
        end else begin
            if (i_run_stop) begin
                if (r_counter == (F_COUNT - 1)) begin
                    r_counter <= 0;
                    o_tick_100hz <= 1'b1;
                end else begin
                    r_counter <= r_counter + 1;
                    o_tick_100hz <= 1'b0;
                end
            end else begin
                o_tick_100hz <= 1'b0;
            end
        end
    end
endmodule

module or_gate (
    input  uart_mode,
    input  orig_mode,
    output select_mode

);

    assign select_mode = uart_mode | orig_mode;

endmodule
