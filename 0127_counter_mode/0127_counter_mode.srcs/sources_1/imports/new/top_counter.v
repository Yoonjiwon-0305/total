`timescale 1ns / 1ps

module top_10000_counter (
    input clk,
    input reset,
    input sw,
    input btn_r,
    input btn_l,
    output [3:0] fnd_digit,
    output [7:0] fnd_data


);
    wire [13:0] w_counter;
    wire w_tick_10hz;
    wire w_run_stop, w_clear, w_mode;
    wire o_btn_run_stop, o_btn_clear;


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
        .i_mode(sw),
        .i_run_stop(o_btn_run_stop),
        .i_clear(o_btn_clear),
        .o_mode(w_mode),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear)
    );


    tick_gen_10hz U_TICK_GEN (
        .clk(clk),
        .reset(reset),
        .i_run_stop(w_run_stop),
        .o_tick_10hz(w_tick_10hz)
    );



    counter_14 U_COUNTER_14 (
        .clk(clk),
        .reset(reset),
        .mode(w_mode),
        .clear(w_clear),
        .run_stop(w_run_stop),
        .i_tick(w_tick_10hz),
        .counter(w_counter)


    );

    fnd_controller U_FND_CNRL (
        .clk(clk),
        .reset(reset),
        .fnd_in_data(w_counter),
        .fnd_digit(fnd_digit),
        .fnd_data(fnd_data)


    );

endmodule

module tick_gen_10hz (
    input clk,
    input reset,
    input i_run_stop,
    output reg o_tick_10hz
);

    reg [$clog2(10_000_000)-1:0] r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter   <= 0;
            o_tick_10hz <= 1'b0;
        end else begin
            if (i_run_stop) begin
                r_counter   <= r_counter + 1;
                o_tick_10hz <= 1'b0;
                if (r_counter == (10_000_000 - 1)) begin
                    r_counter   <= 0;
                    o_tick_10hz <= 1'b1;
                end else begin
                    o_tick_10hz <= 1'b0;
                end
            end
        end
    end
endmodule

module counter_14 (
    input clk,
    input reset,
    input mode,
    input clear,
    input run_stop,
    input i_tick,
    output [13:0] counter

);

    reg [13:0] counter_r;  //100000진 이기때문

    assign counter = counter_r; // 이걸 삽입해주지 않으면 깡통 모듈이 된다.

    // counter_4의 counter_r과 다름// 10만을 log2로 하면 그에 해당하는 비트수를 알려줌

    always @(posedge clk, posedge reset) begin
        if (reset | clear) begin
            counter_r <= 14'd0;
        end else begin
            if (run_stop) begin

                if (mode) begin
                    if (i_tick) begin  // 다운카운트
                        counter_r <= counter_r - 1;
                        if (counter_r == 0) begin
                            counter_r <= 14'd9999;
                        end
                    end
                end else begin

                    if (i_tick) begin  // 업카운트
                        counter_r <= counter_r + 1;

                        if (counter_r == (100_000 - 1)) begin
                            counter_r <= 14'd0;

                        end
                    end
                end
            end
        end
    end


endmodule

