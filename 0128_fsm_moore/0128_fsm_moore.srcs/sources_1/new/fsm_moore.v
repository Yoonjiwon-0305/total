`timescale 1ns / 1ps

module fsm_moore (

    input  clk,
    input  reset,
    input  sw,
    output led

);

    // 무어 모델의 중심은 state register이다.
    //항상 state register 먼저 만든다
    // state 
    parameter s0 = 1'b0, s1 = 1'b1;

    // 현재 current_state
    // 다음 next_state

    // state varialbe 
    reg current_state, next_state;

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
        next_state = current_state;
        case (current_state)
            s0: begin
                if (sw == 1'b1) begin
                    next_state = s1;
                end
            end
            s1: begin
                if (sw == 1'b0) begin
                    next_state = s0;
                end
            end
            default: next_state = current_state;  // 래치 발생 방지
        endcase

    end

    //output 로직
    //assign 구문 사용 예시

    assign led = (current_state == s1) ? 1'b1 : 1'b0;



endmodule

