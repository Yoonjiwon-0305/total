`timescale 1ns / 1ps

module top_stopwatch_watch (
    input        clk,
    input        reset,
    input        btn_r,      //i_run_stop
    input        btn_l,      //i_clear
    input        btn_low,
    input        btn_high,
    input        uart_rx,
    input  [3:0] sw,         //sw[0] up/down
    output [3:0] fnd_digit,
    output [7:0] fnd_data
);


    wire [7:0] w_uart_data, w_dec_mode;
    wire w_uart_done;
    wire [2:0] w_stopwatch_mode;
    wire [3:0] w_watch_mode;
    wire o_btn_sec_up, o_btn_min_up;
    wire o_btn_run_stop, o_btn_clear;
    wire [23:0] w_stopwatch_time, w_watch_time, w_time;
    wire o_run_stop_mode, o_clear_mode, o_sec_up_mode, o_min_up_mode,or_up_down,o_hour_up_mode,o_st_w_mode,o_mode_mode;
    wire w_tg_up_down, w_tg_w_mode, w_tg_sel_mode, w_tg_hour_up;


    wire w_btn_sec_edge, w_btn_min_edge;


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

    sw_toggle U_TG_UP_DOWN (
        .clk  (clk),
        .reset(reset),
        .tick (w_dec_mode[4]),
        .state(w_tg_up_down)
    );

    sw_toggle U_TG_ST_W_MODE (
        .clk  (clk),
        .reset(reset),
        .tick (w_dec_mode[5]),
        .state(w_tg_w_mode)
    );

    sw_toggle U_TG_SEL_MODE (
        .clk  (clk),
        .reset(reset),
        .tick (w_dec_mode[6]),
        .state(w_tg_sel_mode)
    );

    sw_toggle U_TG_HOUR_MODE (
        .clk  (clk),
        .reset(reset),
        .tick (w_dec_mode[7]),
        .state(w_tg_hour_up)
    );

    or_gate U_RUN_STOP_OR (
        .uart_mode  (w_dec_mode[0]),
        .orig_mode  (o_btn_run_stop),
        .select_mode(o_run_stop_mode)

    );
    or_gate U_CLEAR_OR (
        .uart_mode  (w_dec_mode[1]),
        .orig_mode  (o_btn_clear),
        .select_mode(o_clear_mode)

    );
    or_gate U_SEC_UP_OR (
        .uart_mode  (w_dec_mode[2]),
        .orig_mode  (w_btn_sec_edge),
        .select_mode(o_sec_up_mode)

    );
    or_gate U_MIN_UP_OR (
        .uart_mode  (w_dec_mode[3]),
        .orig_mode  (w_btn_min_edge),
        .select_mode(o_min_up_mode)

    );
    or_gate U_UP_DOWN_OR (
        .uart_mode  (w_tg_up_down),
        .orig_mode  (sw[0]),
        .select_mode(o_up_down_mode)

    );
    or_gate U_ST_W_OR (
        .uart_mode  (w_tg_w_mode),
        .orig_mode  (sw[1]),
        .select_mode(o_st_w_mode)

    );
    or_gate U_MODE_OR (
        .uart_mode  (w_tg_sel_mode),
        .orig_mode  (sw[2]),
        .select_mode(o_mode_mode)

    );
    or_gate U_HOUR_UP_OR (
        .uart_mode  (w_tg_hour_up),
        .orig_mode  (sw[3]),
        .select_mode(o_hour_up_mode)

    );

    btn_debounce U_BD_RUNSTOP (
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
    btn_debounce U_BD_SEC_UP (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_low),
        .o_btn(o_btn_sec_up)
    );

    btn_debounce U_BD_MIN_UP (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_high),
        .o_btn(o_btn_min_up)
    );

    edge_detector U_EDGE_SEC (
        .clk(clk),
        .i_sig(o_btn_sec_up),  // 입력 신호 (예: o_btn_sec_up)
        .o_edge(w_btn_sec_edge)  // 추출된 1클럭 틱 신호
    );

    edge_detector U_EDGE_MIN (
        .clk(clk),
        .i_sig(o_btn_min_up),  // 입력 신호 (예: o_btn_sec_up)
        .o_edge(w_btn_min_edge)  // 추출된 1클럭 틱 신호
    );

    control_unit U_CONTROL_UNIT (
        .clk             (clk),
        .reset           (reset),
        .i_up_down       (o_up_down_mode),
        .i_run_stop      (o_run_stop_mode),
        .i_clear         (o_clear_mode),
        .i_sec_up        (o_sec_up_mode),    // edge 신호를 전달
        .i_min_up        (o_min_up_mode),    // edge 신호를 전달
        .i_hour_up       (o_hour_up_mode),
        .o_watch_mode    (w_watch_mode),
        .o_stopwatch_mode(w_stopwatch_mode)
    );

    watch_datapath U_WATCH_DATAPATH (

        .clk  (clk),
        .reset(reset),
        .mode (w_watch_mode),
        .msec (w_watch_time[6:0]),
        .sec  (w_watch_time[12:7]),
        .min  (w_watch_time[18:13]),
        .hour (w_watch_time[23:19])

    );
    stopwatch_datapath U_STOPWATCH_DATAPATH (
        .clk  (clk),
        .reset(reset),
        .mode (w_stopwatch_mode),
        .msec (w_stopwatch_time[6:0]),    //7bit
        .sec  (w_stopwatch_time[12:7]),   //6bit  
        .min  (w_stopwatch_time[18:13]),  //6bit      
        .hour (w_stopwatch_time[23:19])   //6bit
    );


    mux_3x1 U_MUX_3X1 (
        .stopwatch_watch(o_st_w_mode),
        .stopwatchtime(w_stopwatch_time),
        .watchtime(w_watch_time),
        .mux_out_mode(w_time)
    );


    fnd_controller U_FND_CNTL (
        .clk        (clk),
        .reset      (reset),
        .sel_display(o_mode_mode),
        .fnd_in_data(w_time),
        .fnd_digit  (fnd_digit),
        .fnd_data   (fnd_data)
    );


endmodule


module mux_3x1 (
    input             stopwatch_watch,
    input      [23:0] stopwatchtime,
    input      [23:0] watchtime,
    output reg [23:0] mux_out_mode
);

    always @(*) begin
        case (stopwatch_watch)
            1'b0: mux_out_mode <= stopwatchtime;
            1'b1: mux_out_mode <= watchtime;

        endcase
    end

endmodule


module watch_datapath (

    input clk,
    input reset,
    input [3:0] mode,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour

);

    wire w_tick_100hz;
    wire w_tick_msec, w_tick_sec, w_tick_min;

    tick_gen_100hz_wa U_TICK (
        .clk(clk),
        .reset(reset),
        .i_run_stop(1'b1),
        .o_tick_100hz(w_tick_100hz)
    );



    tick_counter_watch #(
        .BIT_WIDTH(7),
        .TIMES(100),
        .INIT(0)
    ) msec_counter (
        .clk(clk),
        .reset(reset),
        .i_tick(w_tick_100hz),
        .up_down(1'b0),
        .sec_up(1'b0),  // msec은 버튼 조작이 필요 없으므로 0 고정
        .min_up(1'b0),
        .hour_up(1'b0),
        .o_count(msec),
        .o_tick(w_tick_msec)
    );
    tick_counter_watch #(
        .BIT_WIDTH(6),
        .TIMES(60),
        .INIT(0)
    ) sec_counter (

        .clk(clk),
        .reset(reset),
        .i_tick(w_tick_msec),
        .up_down(mode[3]),
        .sec_up(mode[2]),
        .min_up(1'b0),
        .hour_up(1'b0),
        .o_count(sec),
        .o_tick(w_tick_sec)
    );
    tick_counter_watch #(
        .BIT_WIDTH(6),
        .TIMES(60),
        .INIT(0)
    ) min_counter (

        .clk(clk),
        .reset(reset),
        .i_tick(w_tick_sec),
        .up_down(mode[3]),
        .sec_up(1'b0),
        .min_up(mode[1]),
        .hour_up(1'b0),
        .o_count(min),
        .o_tick(w_tick_min)
    );
    tick_counter_watch #(
        .BIT_WIDTH(5),
        .TIMES(24),
        .INIT(12)
    ) hour_counter (

        .clk(clk),
        .reset(reset),
        .i_tick(w_tick_min),
        .up_down(mode[3]),
        .sec_up(1'b0),
        .min_up(1'b0),
        .hour_up(mode[0]),
        .o_count(hour),
        .o_tick()
    );
endmodule



module tick_gen_100hz_wa (
    input      clk,
    input      reset,
    input      i_run_stop,
    output reg o_tick_100hz
);
    parameter F_count = 100_000_000 / 100;
    reg [$clog2(F_count)-1:0] counter_r;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_r <= 0;
            o_tick_100hz <= 1'b0;
        end else begin
            if (i_run_stop) begin
                counter_r <= counter_r + 1;
                o_tick_100hz <= 1'b0;
                if (counter_r == (F_count - 1)) begin
                    counter_r <= 0;
                    o_tick_100hz <= 1'b1;
                end else begin
                    o_tick_100hz <= 1'b0;
                end
            end
        end
    end

endmodule

module tick_counter_watch #(
    parameter BIT_WIDTH = 7,
    TIMES = 100,
    INIT = 0
) (
    input clk,
    input reset,
    input i_tick,
    input up_down,
    input sec_up,
    input min_up,
    input hour_up,
    output [BIT_WIDTH-1:0] o_count,
    output reg o_tick
);

    reg [BIT_WIDTH-1:0] counter_reg, counter_next;

    assign o_count = counter_reg;
    //State reg SL
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= INIT;
        end else begin
            counter_reg <= counter_next;
        end
    end

    //next CL
    always @(*) begin
        counter_next = counter_reg;
        o_tick = 1'b0;
        if (i_tick) begin
            if (up_down == 1'b1) begin
                if (counter_reg == 0) begin
                    counter_next = TIMES - 1;
                    o_tick = 1'b1;
                end else begin
                    counter_next = counter_reg - 1;
                end
            end else begin
                if (counter_reg == TIMES - 1) begin
                    counter_next = 0;
                    o_tick = 1'b1;
                end else begin
                    counter_next = counter_reg + 1;
                end
            end
        end

        if (sec_up || min_up || hour_up) begin
            if (counter_reg == TIMES - 1) begin
                counter_next = 0;
            end else begin
                counter_next = counter_reg + 1;
            end
        end
    end

endmodule



module stopwatch_datapath (
    input clk,
    input reset,
    input [2:0] mode,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour

);
    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick;

    tick_gen_100Hz U_TICK (
        .clk(clk),
        .reset(reset),
        .i_run_stop(mode[2]),
        .o_tick_100hz(w_tick_100hz)
    );

    tick_counter #(
        .BIT_WIDTH(7),
        .TIMES(100)
    ) msec_counter (
        .clk(clk),
        .reset(reset),
        .i_tick(w_tick_100hz),
        .run_stop(mode[2]),
        .up_down(mode[1]),
        .clear(mode[0]),
        .o_count(msec),
        .o_tick(w_sec_tick)
    );

    tick_counter #(
        .BIT_WIDTH(6),
        .TIMES(60)
    ) sec_counter (
        .clk(clk),
        .reset(reset),
        .i_tick(w_sec_tick),
        .run_stop(mode[2]),
        .up_down(mode[1]),
        .clear(mode[0]),
        .o_count(sec),
        .o_tick(w_min_tick)
    );
    tick_counter #(
        .BIT_WIDTH(6),
        .TIMES(60)
    ) min_counter (
        .clk(clk),
        .reset(reset),
        .i_tick(w_min_tick),
        .run_stop(mode[2]),
        .up_down(mode[1]),
        .clear(mode[0]),
        .o_count(min),
        .o_tick(w_hour_tick)
    );

    tick_counter #(
        .BIT_WIDTH(5),
        .TIMES(24)
    ) hour_counter (
        .clk(clk),
        .reset(reset),
        .i_tick(w_hour_tick),
        .run_stop(mode[2]),
        .up_down(mode[1]),
        .clear(mode[0]),
        .o_count(hour),
        .o_tick()
    );

endmodule

// msec, sec, min, hour
// tick counter
module tick_counter #(
    parameter BIT_WIDTH = 7,
    TIMES = 100
) (
    input clk,
    input reset,
    input i_tick,
    input run_stop,
    input up_down,
    input clear,
    output [BIT_WIDTH-1:0] o_count,
    output reg o_tick
);

    //counter reg
    reg [BIT_WIDTH-1:0] counter_reg, counter_next;

    assign o_count = counter_reg;
    //State reg SL
    always @(posedge clk, posedge reset) begin
        if (reset) begin  // OR 연산
            counter_reg <= 0;
        end else if (clear) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end

    //next CL
    always @(*) begin
        counter_next = counter_reg;
        o_tick = 1'b0;
        if (clear) begin
            counter_next = 0;

        end else if (i_tick & run_stop) begin
            if (up_down == 1'b1) begin
                //down
                if (counter_reg == 0) begin
                    counter_next = TIMES - 1;
                    o_tick = 1'b1;
                end else begin
                    counter_next = counter_reg - 1;
                    o_tick = 1'b0;
                end
            end else begin
                //up
                if (counter_reg == TIMES - 1) begin
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


module tick_gen_100Hz (
    input      clk,
    input      reset,
    input      i_run_stop,
    output reg o_tick_100hz
);
    parameter F_count = 100_000_000 / 100;
    reg [$clog2(F_count)-1:0] counter_r;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_r <= 0;
            o_tick_100hz <= 1'b0;
        end else begin
            if (i_run_stop) begin
                counter_r <= counter_r + 1;
                o_tick_100hz <= 1'b0;
                if (counter_r == (F_count - 1)) begin
                    counter_r <= 0;
                    o_tick_100hz <= 1'b1;
                end else begin
                    o_tick_100hz <= 1'b0;
                end
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
