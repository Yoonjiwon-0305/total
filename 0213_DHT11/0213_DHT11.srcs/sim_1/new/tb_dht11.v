`timescale 1ns / 1ps

module tb_dht11 ();

    reg clk;
    reg reset;
    reg btn_r;
    reg sw;
    wire dhtio;
    wire [4:0] debug;
    wire [7:0] fnd_data;
    wire [3:0] fnd_digit;

    reg [39:0] test_data;
    reg dhtio_driver;
    reg dht_en;

    assign dhtio = (dht_en) ? 1'bz : dhtio_driver;

    //pullup (dhtio);

    top_dht11_fnd dut (
        .clk(clk),
        .reset(reset),
        .btn_r(btn_r),
        .sw(sw),
        .dhtio(dhtio),
        .debug(debug),
        .fnd_data(fnd_data),
        .fnd_digit(fnd_digit)
    );
    integer i;

    task test_dht11();
        begin
            //START + WAIT
            btn_r = 1;
            #((100_000_000 / 1_000) * 100);
            btn_r = 0;
            //19msec + 30usec
            #(1900 * 10 * 1000 + 30_000);

            dht_en   = 0;
            //SYNC_L
            dhtio_driver = 0;
            #(80_000);  //10us
            //SYNC_H
           dhtio_driver = 1;
            #(80_000);  //10us

            //DATA_C
            for (i = 39; i >= 0; i = i - 1) begin
                dhtio_driver = 0;
                #(50_000);
                if (test_data[i] == 0) begin
                    dhtio_driver = 1'b1;
                    #(28_000);
                end else begin
                    dhtio_driver = 1'b1;
                    #(70_000);
                end
            end
            //STOP
           dhtio_driver= 0;
            #(50_000);  //50us
            dht_en = 1;
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        #0;
        clk =0;
        reset = 1;
        btn_r = 0;
        sw = 0;
        dhtio_driver = 0;
        dht_en  = 1;
        test_data = {8'h32, 8'h00, 8'h19, 8'h00, 8'h4b};

        //reset
        #20;
        reset   = 0;

        test_dht11();
        //test_data = {8'h32, 8'h00, 8'h19, 8'h00, 8'h4b};
        //test_dht11();


        #(100_0000);
        $stop;
    end

endmodule
