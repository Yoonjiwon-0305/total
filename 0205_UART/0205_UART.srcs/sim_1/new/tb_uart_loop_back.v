`timescale 1ns / 1ps



module tb_uart_loop_back ();

    //uart형태로 보내야함

    parameter BAUD_PERIOD = 104160;  // 104_160


    reg clk, reset, rx;
    wire tx;
    reg [7:0] test_data;
    //integer i = 0;
    integer j = 0;

    uart_top dut (
        .clk(clk),
        .reset(reset),
        .uart_rx(rx),
        .uart_tx(tx)

    );
    initial clk = 1'b0;
    always #5 clk = ~clk;

    task uart_sender();
        integer i;
        begin
            rx = 0;

            #(BAUD_PERIOD);
            for (i = 0; i < 8; i = i + 1) begin
                rx = test_data[i];
                #(BAUD_PERIOD);
            end
            rx = 1'b1;
            #(BAUD_PERIOD);

        end
    endtask

    initial begin
        #0;
        reset = 1;
        rx = 1;
        test_data = 8'h30;
        repeat (5) @(posedge clk);
        reset = 1'b0;

        uart_sender();
        for (j = 0; j < 10; j = j + 1) begin
            test_data = 8'h30 + j;
            uart_sender();
        end

        for (j = 0; j < 8; j = j + 1) begin
            #(BAUD_PERIOD);
        end
        //stop 

        $stop;
    end


endmodule
