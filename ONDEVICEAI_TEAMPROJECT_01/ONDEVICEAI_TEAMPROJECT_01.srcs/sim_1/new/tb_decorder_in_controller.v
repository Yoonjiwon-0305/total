`timescale 1ns / 1ps

module tb_decorder_input_controller();

    reg clk;
    reg reset;
    reg [4:0] i_btn_fpga;
    reg [2:0] i_sw_fpga;
    reg [7:0] i_uart_data;
    reg i_uart_done;
    wire [7:0] select_data;

    decorder_input_controller uut (
        .clk(clk),
        .reset(reset),
        .i_btn_fpga(i_btn_fpga),
        .i_sw_fpga(i_sw_fpga),
        .i_uart_data(i_uart_data),
        .i_uart_done(i_uart_done),
        .select_data(select_data)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        i_btn_fpga = 5'b00000;
        i_sw_fpga = 3'b000;
        i_uart_data = 8'h00;
        i_uart_done = 0;

        #20;
        reset = 0;

        #20;
        i_sw_fpga = 3'b100;
        i_btn_fpga = 5'b00001;
        i_uart_data = 8'h72; // 'r'
        i_uart_done = 1;
        #10;                  // 100MHz 기준 1 클락 주기
        i_uart_done = 0;      // 틱(Tick) 신호로 만듦

        #10;
        i_sw_fpga = 3'b010;
        i_btn_fpga = 5'b00010;
        i_uart_data = 8'h6C; // 'l'
        i_uart_done = 1;
        #10;
        i_uart_done = 0;

        #10;
        i_sw_fpga = 3'b001;
        i_btn_fpga = 5'b01000;
        i_uart_data = 8'h75; // 'u'
        i_uart_done = 1;
        #10;
        i_uart_done = 0;

        #10;
        i_sw_fpga = 3'b000;
        i_btn_fpga = 5'b00001;
        i_uart_data = 8'h6C;
        i_uart_done = 1;
        #10;
        i_uart_done = 0;

        #10;
        i_sw_fpga = 3'b000;
        i_btn_fpga = 5'b00100;
        i_uart_data = 8'h75;
        i_uart_done = 1;
        #10;
        i_uart_done = 0;

        #10;
        i_sw_fpga = 3'b111;
        i_btn_fpga = 5'b11111;
        i_uart_data = 8'h72;
        i_uart_done = 1;
        #10;
        i_uart_done = 0;

        #10;
        i_sw_fpga = 3'b000;
        i_btn_fpga = 5'b00000;
        i_uart_data = 8'h64; // 'd'
        i_uart_done = 1;
        #10;
        i_uart_done = 0;

        #1000;
        $stop;
    end

endmodule