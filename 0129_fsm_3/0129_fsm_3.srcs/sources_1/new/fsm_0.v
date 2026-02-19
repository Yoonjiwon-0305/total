`timescale 1ns / 1ps

module fsm_0 (

    input clk,
    input reset,
    input [2:0] sw,
    output  reg[1:0] led

);

    // 무어 모델의 중심은 state register이다.
    //항상 state register 먼저 만든다
    // state 
    parameter s0 = 2'b00, s1 = 2'b01, s2 = 2'b10;

    // 현재 current_state
    // 다음 next_state

    // state varialbe 
    reg [1:0] current_state, next_state;

    // state register
    // 상승엣지가 발생했을때
    always @(posedge clk, posedge reset) begin
        if (reset) begin 
            current_state <= s0;
        end else begin
            current_state <= next_state;
        end
    end

    // next state
    // CL 조합논리

    always @(*) begin
        next_state = current_state;  // 구문의 시작을 초기화
        case (current_state)
            s0: begin
                if (sw == 3'b001) begin
                    next_state = s1;
                end else begin
                    next_state = current_state;
                end
            end
            s1: begin
                if (sw == 3'b010) begin
                    next_state = s2;
                end else begin
                    next_state = current_state;
                end
            end
            s2: begin
                if (sw == 3'b100) begin
                    next_state = s0;
                end else begin
                    next_state = current_state;
                end
            end
            default: next_state = current_state;  // 래치 발생 방지
        endcase

    end

    //assign led = (current_state== s1) ? 2'b01:
                //(current_state ==s2)? 2'b11 : 2'b00;


    //output CL로직
    //assign 구문 사용 예시

    always @(*) begin

        case (current_state)
            s0: 
                led = 2'b00;          
            s1: 
                led = 2'b01;           
            s2: 
                led = 2'b11;
            default: led = 2'b00;
        endcase
    end

endmodule

