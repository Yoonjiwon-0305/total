`timescale 1ns / 1ps

module fsm_1 (

    input clk,
    input reset,
    input [2:0] sw,
    output [2:0] led

);
    // state  
    parameter s0 = 3'b000, s1 = 3'b001, s2 = 3'b010, s3 = 3'b100, s4 = 3'b000;
    //parameter s0 = 3'd0, s1 = 3'd1, s2 = 3'd2, s3 = 3'd3, s4 = 3'd4; 8진수 표현법

    // state varialbe 
    reg [2:0] current_state, next_state;
    reg [2:0] current_led, next_led;

    //output
    assign led = current_led;

    // state register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            current_state <= s0;
            current_led   <= 3'b000;
        end else begin
            current_state <= next_state;
            current_led   <= next_led;
        end
    end

    // next state CL 조합논리

    always @(*) begin
        next_state = current_state;  // 구문의 시작을 초기화
        next_led   = current_led;
        //led = 3'b000;
        case (current_state)
            s0: begin
                next_led = 3'b000;
                if (sw == 3'b001) begin
                    next_state = s1;
                end else if (sw == 3'b010) begin
                    next_state = s2;
                end
            end
            s1: begin
                next_led = 3'b001;
                if (sw == 3'b010) begin
                    next_state = s2;
                end
            end
            s2: begin
                next_led = 3'b010;
                if (sw == 3'b100) begin
                    next_state = s3;
                end
            end
            s3: begin
                next_led = 3'b100;
                if (sw == 3'b000) begin
                    next_state = s0;
                end else if (sw == 3'b111) begin
                    next_state = s4;
                end else if (sw == 3'b011) begin
                    next_state = s1;
                end
            end
            s4: begin
                next_led = 3'b111;
                if (sw == 3'b000) begin
                    next_state = s0;
                end
            end

            default: next_state = current_state;  // 래치 발생 방지
        endcase

    end

    //assign led = (current_state== s1) ? 2'b01:
    //(current_state ==s2)? 2'b11 : 2'b00;

    //output CL로직

    /*always @(*) begin

        case (current_state)
            s0: led = 3'b000;
            s1: led = 3'b001;
            s2: led = 3'b010;
            s3: led = 3'b100;
            s4: led = 3'b111;
            default: led = 3'b000;
        endcase
    end*/

endmodule

