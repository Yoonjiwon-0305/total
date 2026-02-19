`timescale 1ns / 1ps

module tb_top_stopwatch;
    reg clk;
    reg reset;
    reg uart_rx;
    // 기타 입력 버튼 생략 (필요 시 추가)
    reg [3:0] sw_reg;
    wire [3:0] fnd_digit;
    wire [7:0] fnd_data;

    // Top 모듈 인스턴스
    top_stopwatch_watch uut (
        .clk(clk),
        .reset(reset),
        .uart_rx(uart_rx),
        .btn_r(1'b0),
        .btn_l(1'b0),
        .btn_low(1'b0),
        .btn_high(1'b0),
        .sw(sw_reg),
        .fnd_digit(fnd_digit),
        .fnd_data(fnd_data)
    );

    // 100MHz 클럭 생성 (10ns 주기)
    always #5 clk = ~clk;

    // UART 전송 태스크: 실제 9600 보드레이트 속도로 비트를 밀어넣음
    task transmit_uart(input [7:0] data);
        integer i;
        begin
            // Start Bit (Low)
            uart_rx = 0;
            #(104167); // 1 / 9600 * 10^9 ns (약 104us)

            // Data Bits (LSB First)
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i];
                #(104167);
            end

            // Stop Bit (High)
            uart_rx = 1;
            #(104167);
        end
    endtask

    initial begin
        // --- [0] 초기화 ---
        clk = 0;
        reset = 1;
        uart_rx = 1;
        sw_reg = 4'b0000; // 초기 스위치 상태
        #200;
        reset = 0;
        #200;

        // --- [1] Stopwatch Mode Test (sw[1]=0) ---
        // 기본 설정: sw[1]=0 (Stopwatch)
        sw_reg[1] = 0; 
        #1000;

        // ① Run-stop (r): Run 시작
        transmit_uart(8'h72); // 'r'
        #1000000; // 1ms 동안 숫자가 올라가는지 확인

        // ② Run-stop (r): Stop
        transmit_uart(8'h72); // 'r'
        #500000;

        // ③ Clear (l/c): 0으로 초기화
        transmit_uart(8'h6c); // 'l (이미지엔 l로 적혀있으나 코드는 c에 매칭됨)
        #500000;

        // ④ Run-stop (r): 다시 Run (Up 모드)
        transmit_uart(8'h72); // 'r'
        #1000000;

        // ⑤ Up-down (0): Down 모드로 전환
        // 이미지의 (0)은 UART '0' (8'h30)에 해당합니다.
        transmit_uart(8'h30); // '0' 전송하여 Down 모드로 변경
        #2000000; // 숫자가 내려가는지 확인


        // --- [2] Watch Mode Test (sw[1]=1) ---
        // 이미지 설정: sw[1]=1 (Watch Mode)
        transmit_uart(8'h31); // UART '1'을 보내 sw[1] 역할을 하도록 설계했다면 이것 사용
        //sw_reg[1] = 1;        // 물리 스위치 조작 시뮬레이션
        #1000;

        // ① Sec-up (u): 초 증가
        transmit_uart(8'h75); // 'u'
        #500000;

        // ② Mode (2): sw[2]=1 (Hour-Min Mode 변경)
        // 이미지의 (2)는 UART '2' (8'h32)에 해당합니다.
        transmit_uart(8'h32); // '2'
        #500000;

        // ③ Min-up (d): 분 증가 (이미지엔 d로 표시)
        transmit_uart(8'h64); // 'd'
        #500000;

        // ④ Hour-up (3): 시 증가
        transmit_uart(8'h33); // '3'
        #1000000;
        $stop;
    end
endmodule