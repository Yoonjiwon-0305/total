`timescale 1ns / 1ps

module control_unit (
    input      clk,
    input      reset,
    input      i_up_down,
    input      i_run_stop,
    input      i_clear,
    input      i_sec_up,
    input      i_min_up,
    input      i_hour_up,
    output  [4:0]   o_watch_mode,
    output  [2:0]   o_stopwatch_mode
    
);

    localparam [3:0] STOP = 4'b0000, RUN = 4'b0001, CLEAR = 4'b0010, SEC_UP=4'b0100, MIN_UP=4'b1000,HOUR_UP=4'b1100;
    wire w_up_down;
    reg o_run_stop,o_clear,o_sec_up,o_min_up,o_hour_up;
  
    reg [3:0] current_st, next_st;
    assign w_up_down = i_up_down;
    assign w_hour_up = i_hour_up;
    assign o_watch_mode= {w_up_down,o_sec_up,o_min_up,w_hour_up};
    assign o_stopwatch_mode={o_run_stop,w_up_down,o_clear};

   
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_st <= STOP;
        end else begin
            current_st <= next_st;
        end
    end

    always @(*) begin
        next_st = current_st;
        o_run_stop = 1'b0;
        o_clear = 1'b0;
        o_sec_up = 1'b0;
        o_min_up = 1'b0;
        o_hour_up = 1'b0;
        case (current_st)
            STOP: begin
                // moor output
                o_run_stop = 1'b0;
                o_clear = 1'b0;
                o_sec_up = 1'b0;
                o_min_up = 1'b0;
                o_hour_up = 1'b0;
                if (i_run_stop) begin
                    next_st = RUN;
                end else if (i_clear) begin
                    next_st = CLEAR;
                end else if (i_sec_up) begin
                    next_st = SEC_UP;
                end else if (i_min_up) begin
                    next_st = MIN_UP;
                end else if (i_hour_up) begin
                    next_st = HOUR_UP;
                end
            end
            RUN: begin
                o_run_stop = 1'b1;
                o_clear = 1'b0;
                o_sec_up = 1'b0;
                o_min_up = 1'b0;
                o_hour_up = 1'b0;
                if (i_run_stop) begin
                    next_st = STOP;

                end
            end
            CLEAR: begin
                o_run_stop = 1'b0;
                o_clear = 1'b1;
                o_sec_up = 1'b0;
                o_min_up = 1'b0;
                o_hour_up = 1'b0;
                next_st = STOP;
            end
            SEC_UP: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
                o_sec_up = 1'b1;
                o_min_up = 1'b0;
                o_hour_up = 1'b0;
                next_st = STOP;
                
            end
            MIN_UP: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
                o_sec_up = 1'b0;
                o_min_up = 1'b1;
                o_hour_up = 1'b0;
                next_st = STOP;
            end
            HOUR_UP: begin
                o_run_stop = 1'b0;
                o_clear = 1'b0;
                o_sec_up = 1'b0;
                o_min_up = 1'b0;
                o_hour_up = 1'b1;
                next_st = STOP;
            end

        endcase
    end
endmodule
