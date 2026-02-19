`timescale 1ns / 1ps

module top_stopwatch_watch (
    input        clk,
    input        reset,
    input        btn_r,      //i_run_stop
    input        btn_l,      //i_clear
    input        btn_low,
    input        btn_high,
    input  [3:0] sw,         //sw[0] up/down
    output [3:0] fnd_digit,
    output [7:0] fnd_data
);

    //assign o_watch_mode= {w_up_down, o_sec_up ,o_min_up, w_hour_up};
    //assign o_stopwatch_mode={o_run_stop, w_up_down, o_clear};

    wire [13:0] w_counter;
    wire [ 2:0] w_stopwatch_mode;
    wire [ 3:0] w_watch_mode;
    wire o_sec_up, o_min_up;
    wire o_btn_run_stop, o_btn_clear;
    wire [23:0] w_stopwatch_time, w_watch_time, w_time;

    reg r_sec_up, r_min_up, r_hour_up;
    wire w_sec_up_edge, w_min_up_edge, w_hour_edge;

    always @(posedge clk) begin
        r_sec_up  <= o_sec_up;
        r_min_up  <= o_min_up;
        r_hour_up <= sw[3];
    end

    assign w_sec_up_edge = o_sec_up & ~r_sec_up;
    assign w_min_up_edge = o_min_up & ~r_min_up;
    assign w_hour_edge   = sw[3] & ~r_hour_up;

    btn_debounce U_BD_SEC_UP (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_low),
        .o_btn(o_sec_up)
    );

    btn_debounce U_BD_MIN_UP (
        .clk  (clk),
        .reset(reset),
        .i_btn(btn_high),
        .o_btn(o_min_up)
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

    control_unit U_CONTROL_UNIT (
        .clk             (clk),
        .reset           (reset),
        .i_up_down       (sw[0]),
        .i_run_stop      (o_btn_run_stop),
        .i_clear         (o_btn_clear),
        .i_sec_up        (w_sec_up_edge),    // edge 신호를 전달
        .i_min_up        (w_min_up_edge),    // edge 신호를 전달
        .i_hour_up       (w_hour_edge),
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
        .stopwatch_watch(sw[1]),
        .stopwatchtime(w_stopwatch_time),
        .watchtime(w_watch_time),
        .mux_out_mode(w_time)
    );


    fnd_controller U_FND_CNTL (
        .clk        (clk),
        .reset      (reset),
        .sel_display(sw[2]),
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
        if (reset | clear) begin  // OR 연산
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end

    //next CL
    always @(*) begin
        counter_next = counter_reg;
        o_tick = 1'b0;
        if (i_tick & run_stop) begin
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
