`timescale 1ns / 1ps

module ascii_decorder (

    input            clk,
    input            reset,
    input      [7:0] uart_data,
    input            uart_done,
    output reg [7:0] uart_mode

);
    always @(posedge clk or posedge reset) begin
        if (reset) begin

            uart_mode <= 8'b0;
        end else begin

            if (uart_done) begin
                case (uart_data)
                    8'h72:   uart_mode <= 8'h01;  // 'r'
                    8'h6c:   uart_mode <= 8'h02;  // 'l'
                    8'h75:   uart_mode <= 8'h04;  // 'u'
                    8'h64:   uart_mode <= 8'h08;  // 'd'
                    8'h30:   uart_mode <= 8'h10;  // '0'
                    8'h31:   uart_mode <= 8'h20;  // '1'
                    8'h32:   uart_mode <= 8'h40;  // '2'
                    8'h33:   uart_mode <= 8'h80;  // '3'
                    default: uart_mode <= 8'b0;
                endcase
            end else begin
                uart_mode <= 8'b0;
            end
        end
    end


endmodule
// 반전
///유지되는 상태 값 신호 (UART 틱 등)
// 틱이 들어올 때마다 반전

module sw_toggle (
    input      clk,
    input      reset,
    input      tick,   
    output reg state   
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 1'b0;
        end else if (tick) begin
            state <= ~state;  
        end
    end
endmodule

module edge_detector (
    input  clk,
    input  i_sig,  // 입력 신호 (예: o_btn_sec_up)
    output o_edge  // 추출된 1클럭 틱 신호
);

    reg r_sig_prev;

    always @(posedge clk) begin
        r_sig_prev <= i_sig;  // 이전 클럭의 신호 상태 저장
    end

    // 현재는 1(High)인데 이전에는 0(Low)였던 순간을 포착 (상승 엣지)
    assign o_edge = i_sig & ~r_sig_prev;

endmodule

