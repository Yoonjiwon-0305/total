`timescale 1ns / 1ps

module top_10000_counter (
    input clk,
    input reset,
    output [3:0] fnd_digit,
    output [7:0] fnd_data


);
    wire [13:0] w_counter;
    wire w_tick_10hz;

    tick_gen_10hz U_TICK_GEN (
        .clk(clk),
        .reset(reset),
        .o_tick_10hz(w_tick_10hz)
    );



    counter_14 U_COUNTER_14 (
        .clk(clk),
        .reset(reset),
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
    output reg o_tick_10hz
);

    reg [$clog2(10_000_000)-1:0] r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter   <= 0;
            o_tick_10hz <= 1'b0;
        end else begin
            r_counter   <= r_counter + 1;
            o_tick_10hz <= 1'b0;
            if (r_counter == (10_000_000 - 1)) begin
                r_counter   <= 0;
                o_tick_10hz <= 1'b1;
            end else begin
                o_tick_10hz <= 1'b0;
            end
        end
    end // 또는 or이므로 비동기 방식
endmodule

module counter_14 (
    input clk,
    input reset,
    input i_tick,
    output [13:0] counter

);

    reg [13:0] counter_r;  //100000진 이기때문

    assign counter = counter_r;

    // counter_4의 counter_r과 다름// 10만을 log2로 하면 그에 해당하는 비트수를 알려줌

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            // reset inits
            counter_r <= 14'd0;
            // counter_data <= 1'b0;
        end else begin
            //to do
            if (i_tick) begin // 틱이 1일때 만 카운트 , 틱이 1이고  clk이 상승엣지일때 카운트 1
                counter_r <= counter_r + 1;
            end
            if (counter_r == 10000 - 1) begin  //9999까지 
                counter_r <= 14'd0;
            end
        end
    end
endmodule

