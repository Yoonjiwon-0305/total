`timescale 1ns / 1ps

module fsm_moore_01 (

    input  clk,
    input  reset,
    input  din_bit,
    output  dout_bit

);

    // 무어 모델의 중심은 state register이다.
    //항상 state register 먼저 만든다
    // state 
    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100;

    // 현재 current_state
    // 다음 next_state

    // state varialbe 
    reg [2:0]current_state, next_state;
    

    // state register
    // 상승엣지가 발생했을때
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            current_state <= S0;
        end else begin
            current_state <= next_state;
        end
    end

    // next state
    // CL 조합논리

    always @(*) begin
        next_state = current_state;
        //dout_bit=1'b0;
        case (current_state)
            S0: begin
                if (din_bit == 1'b0) begin
                    next_state = S1;
                end
            end
            S1: begin
                if (din_bit == 1'b1) begin
                    next_state = S2;
                end
            end
            S2: begin
                if (din_bit == 1'b0) begin
                    next_state = S3;
                end else if (din_bit == 1'b1) begin
                    next_state = S0;
                end
            end
            S3: begin
                if (din_bit == 1'b1) begin
                    next_state = S4;
                end else if (din_bit == 1'b0) begin
                    next_state = S1;
                end
            end
            S4: begin
                if (din_bit == 1'b1) begin
                    next_state = S0;
                end else if (din_bit == 1'b0) begin
                    next_state = S1;
                    
                end
            end

            default: next_state = current_state;  // 래치 발생 방지
        endcase

    end

    //output 로직
    //assign 구문 사용 예시

    assign dout_bit = (current_state == S4) ? 1'b1 : 1'b0;



endmodule

