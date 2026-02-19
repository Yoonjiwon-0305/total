`timescale 1ns / 1ps

//CLK = 
//FREQUENCY = hz
module tick_gen_100hz #(
    parameter CLK = 100_000_000,
    FREQUENCY = 100
) (
    input      clk,
    input      reset,
    input      i_run_stop,
    output reg o_tick
);
    parameter F_COUNT = CLK / FREQUENCY;
    reg [$clog2(F_COUNT)-1:0] r_counter;


    //r_counter
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            if (i_run_stop) begin
                if (r_counter == (F_COUNT - 1)) begin
                    r_counter <= 0;
                end else begin
                    r_counter <= r_counter + 1;
                end
            end
        end
    end

    //o_tick_counter
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            o_tick <= 1'b0;
        end else begin
            if (i_run_stop) begin
                if (r_counter == (F_COUNT - 1)) begin
                    o_tick <= 1'b1;
                end else begin
                    o_tick <= 1'b0;
                end
            end
        end
    end

endmodule
