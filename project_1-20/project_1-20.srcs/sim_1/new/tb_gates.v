`timescale 1ns / 1ps //  시간 단위 설정, 1nano sec 10^-9 ,1pico sec 10^-12
// 동작단위 / 해석단위 (시뮬레이션 분석)
// 1ns 으로 바꿨을때 노이즈 많이 섞임 하지만 빠르게 결과를 볼 수있다


module tb_gates( );
reg a,b;
wire y0,y1,y2,y3,y4,y5,y6;

//top module
gates dut(
    .a(a),
    .b(b),
    .y0(y0),
    .y1(y1),
    .y2(y2),
    .y3(y3),
    .y4(y4),
    .y5(y5),
    .y6(y6)
);
initial begin
    #0;
    a=0;
    b=0;

    #10;
    a=1;
    b=0;

    #10;
    a=0;
    b=1;

    #10;
    a=1;
    b=1;
    #10;
    $stop;

end
endmodule
