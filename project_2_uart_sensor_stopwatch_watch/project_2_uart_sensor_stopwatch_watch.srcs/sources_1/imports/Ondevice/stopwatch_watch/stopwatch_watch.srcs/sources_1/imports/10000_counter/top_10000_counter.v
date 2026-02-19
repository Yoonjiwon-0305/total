`timescale 1ns / 1ps

module top_10000_counter (
    input        clk,
    input        reset,
    input        sw,            // sw[0] up/down
    input        btn_r,         // i_run_stop
    input        btn_l,         //i_clear
    output [7:0] fnd_data,
    output [3:0] fnd_digit
);

    wire w_tick_10hz;
    wire [13:0] w_counter_out;
    wire w_run_stop, w_clear, w_mode;
    wire o_btn_run_stop, o_btn_claer;

    btn_debounce U_BTN_D_RUN_STOP(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_r),
        .o_btn(o_btn_run_stop)
    );

    btn_debounce U_BTN_D_CLEAR(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_l),
        .o_btn(o_btn_claer)
    );

    control_unit U_COTROL_UNIT (
        .clk(clk),
        .reset(reset),
        .i_mode(sw),
        .i_run_stop(o_btn_run_stop),
        .i_clear(o_btn_claer),
        .o_mode(w_mode),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear)
    );

    fnd_controller U_FND_CTLR (
        .clk        (clk),
        .reset      (reset),
        .fnd_in_data(w_counter_out),
        .fnd_data   (fnd_data),
        .fnd_digit  (fnd_digit)
    );

    counter_10000 U_COUNTER_10000 (
        .clk(clk),
        .reset(reset),
        .mode(w_mode),
        .run_stop(w_run_stop),
        .clear(w_clear),
        .i_tick(w_tick_10hz),
        .counter_out(w_counter_out)
    );

    /*tick_generator U_TICK_GENERATOR (
        .clk(clk),
        .reset(reset),
        .i_run_stop(w_run_stop),
        .o_tick_10hz(w_tick_10hz)
    );*/

endmodule


module counter_10000 (
    input         clk,
    input         reset,
    input         mode,
    input         run_stop,
    input         clear,
    input         i_tick,
    output [13:0] counter_out
);
    //mode = 0: upcount     mode = 1: downcount
    //run_stop = 0: stop    run_stop = 1: run
    //clear = 0: nothing    clear = 1: claer count vlaue


    reg [13:0] counter;

    always @(posedge clk or posedge reset) begin
        //reset clear
        if (reset | clear) begin
            counter <= 14'b0;
        end else begin
            //run_stop
            if (run_stop) begin
                //mode
                if (mode) begin
                    if (i_tick) begin
                        counter <= counter - 14'b1;
                        if (counter == 14'b0) begin
                            counter <= 14'd9999;
                        end
                    end
                end else begin
                    if (i_tick) begin
                        counter <= counter + 14'b1;
                        if (counter == 14'd9999) begin
                            counter <= 14'b0;
                        end
                    end
                end
            end
        end
    end

    assign counter_out = counter;

endmodule
