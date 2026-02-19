`timescale 1ns / 1ps
/*
module full_adder_8bit (
    input [7:0]a,b,
   
    input cin,
    output [7:0] sum,
    output c
);

    full_adder_8nit U_FA_8bit(
        .a0(a[0]),// bit 자리
        .b0(b[0]),
        .a1(a[1]),
        .b1(b[1]),
        .a2(a[2]),
        .b2(b[2]),
        .a3(a[3]),
        .b3(b[3]),
        .a4(a[4]),// bit 자리
        .b4(b[4]),
        .a5(a[5]),
        .b5(b[5]),
        .a6(a[6]),
        .b6(b[6]),
        .a7(a[7]),
        .b7(b[7]),
        .cin(1'b0), // 1;bit 수 ,b: binary 2진수 ,==> 1bit 짜리 binary 숫자값 0
        .sum0(sum[0]),
        .sum1(sum[1]),
        .sum2(sum[2]),
        .sum3(sum[3]),
        .sum0(sum[4]),
        .sum1(sum[5]),
        .sum2(sum[6]),
        .sum3(sum[7]),
        .c(c)
    );
    
endmodule

*/
module top_adder (
    input [7:0] a,
    input [7:0] b,
    output [3:0] fnd_digit,
    output [7:0] fnd_data,
    output c

);
// top_adder 안에 8bit adder 와 bcd가 있으므로 인스턴스를 해줘야함 아래가 그과정

wire [7:0] w_sum;
    fnd_controller U_FND_CNRL(
    .sum(w_sum),
    .fnd_digit(fnd_digit),
    .fnd_data(fnd_data)


);
    adder U_ADDER(
    .a(a), 
    .b(b),
    .sum(w_sum),
    .c(c)
);
    
endmodule
module  adder(
    input [7:0] a, // 
    input[7:0]b,
    output [7:0] sum,// 벡터형 
    output c
);
wire w_fa4_0_c;
full_adder_4bit U_FA4_1(
    .a0(a[4]),// bit 자리
    .b0(b[4]),
    .a1(a[5]),
    .b1(b[5]),
    .a2(a[6]),
    .b2(b[6]),
    .a3(a[7]),
    .b3(b[7]),
    .cin(w_fa4_0_c), // 1;bit 수 ,b: binary 2진수 ,==> 1bit 짜리 binary 숫자값 0
    .sum0(sum[4]),
    .sum1(sum[5]),
    .sum2(sum[6]),
    .sum3(sum[7]),
    .c(c)
);
full_adder_4bit U_FA4_0 (
    .a0(a[0]),// bit 자리
    .b0(b[0]),
    .a1(a[1]),
    .b1(b[1]),
    .a2(a[2]),
    .b2(b[2]),
    .a3(a[3]),
    .b3(b[3]),
    .cin(1'b0), // 1;bit 수 ,b: binary 2진수 ,==> 1bit 짜리 binary 숫자값 0
    .sum0(sum[0]),
    .sum1(sum[1]),
    .sum2(sum[2]),
    .sum3(sum[3]),
    .c(w_fa4_0_c)
);
endmodule

module full_adder_4bit (
    input a0,
    input b0,
    input a1,
    input b1,
    input a2,
    input b2,
    input a3,
    input b3,
    input cin,
    output sum0,sum1,sum2,sum3,
    output c
);
    
    wire w_fa0_c, w_fa1_c, w_fa2_c;

    full_adder U_FA3(
        .a(a3),
        .b(b3),
        .cin(w_fa2_c),
        .sum(sum3),
        .c(c)//.c(w_fa3_c) 으로 하게 되면 선이 끊긴다. 선언을 안해주더라도 자기가 있는걸로 인식
    );

    full_adder U_FA2(
        .a(a2),
        .b(b2),
        .cin(w_fa1_c),
        .sum(sum2),
        .c(w_fa2_c)
    );

    full_adder U_FA1(
        .a(a1),
        .b(b1),
        .cin(w_fa0_c),
        .sum(sum1),
        .c(w_fa1_c)
    );

     full_adder U_FA0(
        .a(a0),
        .b(b0),
        .cin(cin),
        .sum(sum0),
        .c(w_fa0_c)
    );

endmodule


module full_adder (
    input  a,
    input  b,
    input  cin,
    output sum,
    output c

);

    wire w_ha_sum,w_ha0_c, w_ha1_c;
    assign c = w_ha0_c | w_ha1_c;// to full adder output c

    half_adder U_HA1 (  // wire 타입이므로 선언 안해도 됌
        .a(w_ha_sum), // () 안의 a는  full adder input a  // 밖의 a는 half adder input a
        .b(cin),
        .sum(sum),
        .carry(w_ha1_c)

    );

    half_adder U_HA0 (
        .a(a),
        .b(b),
        .sum(w_ha_sum),
        .carry(w_ha0_c)       
        
    ); 
endmodule

module half_adder (
    input  a,
    input  b,
    output sum,
    output carry

);
    // half_adder
    assign sum   = a ^ b;
    assign carry = a & b;
endmodule

/*module full_adder (
    input  a0,a1,a2,a3,
    input  b0,b1,b2,b3, // 총 입력 9개
    input  cin,
    output sum0,sum1,sum2,sum3,
    output c // 총 출력 5개
);
    wire w_carry0;
    wire w_ha_sum0,// FA0 에서 나온 sum0
    w_ha_sum1, // FA1 에서 나온 sum1
    w_ha_sum2, // FA2 에서 나온 sum2
    w_ha_sum3, // FA3 에서 나온 sum3
    w_ha0_c, //FA0 에서 나온 carry
    w_ha1_c, //FA1 에서 나온 carry
    w_ha2_c; //FA2 에서 나온 carry
    *//*
    full_adder U_HA3 (  // wire 타입이므로 선언 안해도 됌
        .a(a3), // () 안의 a는  full adder input a  // 밖의 a는 half adder input a
        .b(b3),
        .cin(w_ha2_c),
        .sum(sum3),
        .carry(c)
    );
    // FA0 기준 입력 a=a3 , b=b3 ,cin= FA2에서 나온 carry, 
    // 출력 sum=sum3 , carry=FA3에서 나온 carry
   full_adder U_HA2 (
        .a(a2),
        .b(b2),
        .cin(w_ha1_c),
        .sum(sum2),
        .carry(w_ha2_c)     
            ); 
    // FA0 기준 입력 a=a2 , b=b2 ,cin= FA1에서 나온 carry, 
    // 출력 sum=sum2 , carry=FA2에서 나온 carry
   full_adder U_FA1 (
        .a(a1),
        .b(b1),
        .cin(w_ha0_c),
        .sum(sum1),
        .carry(w_ha1_c)          
    ); 
    // FA0 기준 입력 a=a1 , b=b1 ,cin=FA0에서 나온 carry , 
    // 출력 sum=sum1 , carry=FA1에서 나온 carry
    full_adder U_FA0 (
        .a(a0),
        .b(b0),
        .cin(cin),
        .sum(sum0),
        .carry(w_ha0_c)         
    ); 
    // FA0 기준 입력 a=a0 , b=b0 ,cin= cin, 
    // 출력 sum=sum0 , carry=FA0에서 나온 carry
endmodule*/
/*module full_adder (
    input  a,
    input  b,
    input  cin,
    output sum,
    output c

);

    wire w_ha_sum,w_ha0_c, w_ha1_c;
    assign c = w_ha0_c | w_ha1_c;// to full adder output c

    half_adder U_HA1 (  // wire 타입이므로 선언 안해도 됌
        .a(w_ha_sum), // () 안의 a는  full adder input a  // 밖의 a는 half adder input a
        .b(cin),
        .sum(sum),
        .carry(w_ha1_c)

    );

    half_adder U_HA0 (
        .a(a),
        .b(b),
        .sum(w_ha_sum),
        .carry(w_ha0_c)       
        
    ); 
endmodule*/