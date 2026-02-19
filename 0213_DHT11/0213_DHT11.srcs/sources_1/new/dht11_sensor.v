`timescale 1ns / 1ps

module dht11_controller (

    input         clk,
    input         reset,
    input         start,
    output [27:0] dht_data,
    output        dht11_done,
    output        dht11_valid,
    output [ 4:0] debug,
    inout         dhtio
);

    wire tick_1u;

    tick_gen_1u U_TICK_1u (
        .clk(clk),
        .reset(reset),
        .tick_1u(tick_1u)
    );

    //ila_0 U_ILA0 (
    //    .clk(clk),
    //    .probe0(dhtio),  // 1bit
    //    .probe1(debug)  //5bit
    //);

    // state  
    parameter IDLE = 0, START =1, WAIT = 2,SYNC_L= 3,SYNC_H=4, DATA_SYNC=5, DATA_CAL=6, CHECK_SUM=7, STOP=8;
    reg [3:0] current_state, next_state;

    reg [15:0] humidity_reg, humidity_next;
    reg [15:0] temperature_reg, temperature_next;


    reg dht11_valid_reg, dht11_valid_next;
    reg dht11_done_reg, dht11_done_next;
    reg [39:0] data_reg_reg, data_reg_next;
    reg [5:0] data_cnt_reg, data_cnt_next;
    reg dhtio_sync2_reg, dhtio_sync2_next;
    reg io_sel_reg, io_sel_next;
    reg [$clog2(19000)-1:0] tick_cnt_reg, tick_cnt_next;

    
    assign dht_data = {humidity_reg[14:8],humidity_reg[6:0],temperature_reg[14:8],temperature_reg[6:0]};
    
    assign dht11_valid = dht11_valid_reg;
    assign dht11_done = dht11_done_reg;
    assign dhtio = (io_sel_reg) ? dhtio_sync2_reg : 1'bz;//tri buffer
    assign debug = {dht11_valid,current_state};

    reg dhtio_sync1, dhtio_sync2;

    // synconizer
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            dhtio_sync1 <= 1'b1;
            dhtio_sync2 <= 1'b1;
        end else begin
            dhtio_sync1 <= dhtio;  // 1단
            dhtio_sync2 <= dhtio_sync1;  // 2단 
        end
    end

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            current_state   <= IDLE;
            dhtio_sync2_reg <= 1'b1;
            io_sel_reg      <= 1'b1;
            tick_cnt_reg    <= 0;
            data_reg_reg    <= 0;
            data_cnt_reg    <= 0;
            humidity_reg    <= 0;
            temperature_reg <= 0;
            dht11_valid_reg <= 0;
            dht11_done_reg  <= 0;
        end else begin
            current_state   <= next_state;
            dhtio_sync2_reg <= dhtio_sync2_next;
            io_sel_reg      <= io_sel_next;
            tick_cnt_reg    <= tick_cnt_next;
            data_reg_reg    <= data_reg_next;
            data_cnt_reg    <= data_cnt_next;
            humidity_reg    <= humidity_next;
            temperature_reg <= temperature_next;
            dht11_valid_reg <= dht11_valid_next;
            dht11_done_reg  <= dht11_done_next;
        end
    end

    always @(*) begin
        next_state       = current_state;
        dhtio_sync2_next = dhtio_sync2_reg;
        io_sel_next      = io_sel_reg;
        tick_cnt_next    = tick_cnt_reg;
        data_reg_next    = data_reg_reg;
        data_cnt_next    = data_cnt_reg;
        humidity_next    = humidity_reg;
        temperature_next = temperature_reg;
        dht11_valid_next = dht11_valid_reg;
        dht11_done_next  = dht11_done_reg;

        case (current_state)
            IDLE: begin
                dhtio_sync2_next = 1'b1;
                if (start) begin
                    next_state = START;
                end
            end
            START: begin
                dhtio_sync2_next = 1'b0;
                if (tick_1u) begin
                    tick_cnt_next = tick_cnt_reg + 1;
                    if (tick_cnt_reg == 19000) begin  // 19msec=19_000u 지연 ,1msec=1_000u
                        tick_cnt_next = 0;
                        next_state = WAIT;
                    end

                end
            end
            WAIT: begin
                dhtio_sync2_next = 1'b1;
                if (tick_1u) begin
                    tick_cnt_next = tick_cnt_reg + 1;
                    if (tick_cnt_reg == 30) begin  // 30u 만큼 지연
                        // for output to high-z
                        tick_cnt_next = 0;
                        io_sel_next = 1'b0;  // 출력 끊은것
                        next_state = SYNC_L;
                    end
                end
            end
            SYNC_L: begin  // synconizer 설치하면 좋음
                if (tick_1u) begin
                    if (dhtio_sync2 == 1) begin
                        next_state = SYNC_H;
                    end
                end
            end
            SYNC_H: begin
                if (tick_1u) begin
                    if (dhtio_sync2 == 0) begin
                        next_state = DATA_SYNC;
                    end
                end
            end
            DATA_SYNC: begin
                if (tick_1u) begin
                    if (dhtio_sync2 == 1) begin
                        tick_cnt_next = 0;
                        next_state = DATA_CAL;
                    end

                end
            end
            DATA_CAL: begin
                if (tick_1u) begin
                    if (dhtio_sync2 == 1) begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end else begin
                        if (tick_cnt_reg >= 40) begin
                            data_reg_next = {data_reg_reg[38:0], 1'b1};
                            tick_cnt_next = 0;
                        end else begin
                            data_reg_next = {data_reg_reg[38:0], 1'b0};
                            tick_cnt_next = 0;
                        end

                        if (data_cnt_reg == 39) begin
                            data_cnt_next = 0;
                            next_state = CHECK_SUM;
                        end else begin
                            data_cnt_next = data_cnt_reg + 1;
                            next_state = DATA_SYNC;
                        end
                    end
                end
            end
            CHECK_SUM: begin
                if (data_reg_reg[39:32] + data_reg_reg[31:24] + data_reg_reg[23:16] + data_reg_reg[15:8] == data_reg_reg[7:0]) begin
                    humidity_next = data_reg_reg[39:24];
                    temperature_next = data_reg_reg[23:8];
                    dht11_valid_next = 1'b1;
                end else begin
                    dht11_valid_next = 1'b0;
                end
                dht11_done_next = 1'b1;
                next_state = STOP;
            end
            STOP: begin
                if (tick_1u) begin
                    tick_cnt_next = tick_cnt_reg + 1;
                    if (tick_cnt_reg == 50) begin
                        dhtio_sync2_next = 1'b1;
                        io_sel_next = 1'b1;
                        next_state = IDLE;
                    end
                end
                dht11_done_next = 1'b0;
            end
        endcase
    end
endmodule

module tick_gen_1u (

    input      clk,
    input      reset,
    output reg tick_1u
);
    //100_000_000/100_000
    parameter F_count = 100_000_000 / 1_000_000;
    reg [$clog2(F_count)-1:0] counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            tick_1u <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == F_count - 1) begin
                counter_reg <= 0;
                tick_1u <= 1'b1;

            end else begin
                tick_1u <= 1'b0;
            end
        end

    end
endmodule
