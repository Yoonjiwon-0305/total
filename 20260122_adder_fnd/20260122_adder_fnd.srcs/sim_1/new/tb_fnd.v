`timescale 1ns / 1ps

module tb_fnd();
    
    reg [7:0] a;
    reg [7:0] b;   
    wire [3:0] fnd_digit;
    wire [7:0] fnd_data;
    wire c;

    
     
    top_adder dut (
        .a(a),
        .b(b),
        .fnd_digit(fnd_digit),
        .fnd_data(fnd_data),
        .c(c)
    );

    initial begin
        #0;
        a=8'b0000_0000; //0
        b=8'b0000_0000; //0

        #10;//
        a=8'b0000_0001; //1
        b=8'b0000_0111; //7

        #10;
        a=8'b0000_0100; //4
        b=8'b0000_0011; //3

        #10;
        a=8'b0000_0010; //2
        b=8'b0000_0001; //1

        #10;
        a=8'b0000_0110; //6
        b=8'b0000_0011; //3

        #10;
        
        $finish;       
        

    end

endmodule
