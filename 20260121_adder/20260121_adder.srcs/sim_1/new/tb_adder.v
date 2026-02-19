`timescale 1ns / 1ps
module tb_adder ();  // 테스트 벤치는 입출력이 없다.
    // tb_adder local 변수
    reg [7:0] a,b; 
    wire [7:0] sum;
    wire c;

    integer i = 0, j = 0;  // 데이터 타입 : 2type , 32bit 까지만
    // 변수 integer 선언 할때는 init문 밖에서 선언해야한다

    adder dut (
        .a  (a),
        .b  (b),
        .sum(sum),
        .c  (c)
    );

    initial begin
        #0;
        a = 8'b0000_0000;//_ 는 보기좋게 하기위한 삽입
        b = 8'b0000_0000;

        #10;
        for (i = 0; i < 256; i = i + 1) begin
            for (j = 0; j < 256; j = j + 1) begin
                a = i;
                b = j;
                #10;// 시뮬레이션이기 때문에 시간을 주어 지연시켜야함
            end
        end

        $stop;
    end

endmodule
