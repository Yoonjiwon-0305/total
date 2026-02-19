`timescale 1ns / 1ps

module tb_fsm_mealy;

    // 입력 신호 선언
    reg  clk;
    reg  reset;
    reg  din_bit;

    // 출력 신호 선언
    wire dout_bit;

    // DUT 인스턴스화 
    fsm_mealy dut (
        .clk(clk),
        .reset(reset),
        .din_bit(din_bit),
        .dout_bit(dout_bit)
    );

    always #5 clk = ~clk;

    initial begin
        // 초기값 설정
        clk = 0;
        reset = 1;
        din_bit = 0;

        // 리셋 신호
        #10;
        reset = 0;
        #10;//20
        // 입력 신호 패턴
        #10 din_bit = 1;//30

        #10 din_bit = 0;//40

        #10 din_bit = 1;//50
        
        #10 din_bit = 0;//60

        #10 din_bit = 1;//70

        #10 din_bit = 0;//80,90
        //#10 din_bit = 0
        #20 din_bit = 1;//100,110
        //#10 din_bit = 1;
        #20 din_bit = 0;//120
        //
        #10 din_bit = 1;//130

        #10 din_bit = 0;//140,150

        #20 din_bit = 1;//160,170

        #20 din_bit = 0;///180
        // 시뮬레이션 종료
        #10 $stop;
    end


endmodule
