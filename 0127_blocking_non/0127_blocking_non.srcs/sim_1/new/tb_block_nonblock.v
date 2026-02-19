`timescale 1ns / 1ps

module tb_block_nonblock();

    reg a,b,c;

    initial begin
        #0;
        // blocking 연산// 한줄한줄 실행 
        a=1;
        b=0;
        c=a+b;

        #10;
        // 순차적으로 실행=> block

        a=b;
        b=a;
        c=a+b;

        #10;
        //non-blocking // 동시 처리 // 순서가 없음
        a=1;
        b=0;

        #10;
        //non-blocking  // 동시 처리
        a<=b;
        b<=a;
        c<=a+b;          
        
        #10;
        $stop;


    end

    
endmodule
