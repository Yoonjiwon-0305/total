`timescale 1ns / 1ps


module uart_top (
    input clk,
    input reset,
    input uart_rx,
    output uart_tx


);

    wire w_b_tick;
    wire [7:0] w_rx_data;
    assign uart_data = w_rx_data;

    wire [7:0] w_tx_fifo_pop_data, w_rx_fifo_pop_data;
    wire w_tx_fifo_full, w_rx_fifo_full, w_tx_busy, w_tx_fifo_empty,w_rx_fifo_empty;
    uart_rx U_UART_RX (
        .clk(clk),
        .reset(reset),
        .rx(uart_rx),
        .b_tick(w_b_tick),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)

    );
    fifo U_FIFO_RX (

        .clk(clk),
        .reset(reset),
        .push(w_rx_done),
        .pop(~w_tx_fifo_full),
        .push_data(w_rx_data),
        .pop_data(w_rx_fifo_pop_data),
        .full(),
        .empty(w_rx_fifo_empty)

    );


    fifo U_FIFO_TX (

        .clk(clk),
        .reset(reset),
        .push(~w_rx_fifo_empty),
        .pop(~w_tx_busy),
        .push_data(w_rx_fifo_pop_data),
        .pop_data(w_tx_fifo_pop_data),
        .full(w_tx_fifo_full),
        .empty(w_tx_fifo_empty)

    );

    uart_tx U_UART_TX (
        .clk(clk),
        .reset(reset),
        .tx_start(~w_tx_fifo_empty),
        .b_tick(w_b_tick),
        .tx_data(w_tx_fifo_pop_data),
        .uart_tx(uart_tx),
        .tx_busy(w_tx_busy),
        .tx_done()
    );

    baud_tick U_BAUD_TICK (
        .clk(clk),
        .reset(reset),
        .b_tick(w_b_tick)
    );


endmodule

module uart_rx (
    input        clk,
    input        reset,
    input        rx,
    input        b_tick,
    output [7:0] rx_data,
    output       rx_done

);
    reg [1:0] current_state, next_state;
    reg [4:0] b_tick_cnt_reg, b_tick_cnt_next;
    reg [2:0] bit_cnt_next, bit_cnt_reg;
    reg done_reg, done_next;
    reg [7:0] buf_reg, buf_next;

    localparam [1:0] IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;

    assign rx_data = buf_reg;
    assign rx_done = done_reg;

    // state register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            current_state  <= IDLE;
            b_tick_cnt_reg <= 0;
            bit_cnt_reg    <= 0;
            done_reg       <= 0;
            buf_reg        <= 0;
        end else begin
            current_state  <= next_state;
            b_tick_cnt_reg <= b_tick_cnt_next;
            bit_cnt_reg    <= bit_cnt_next;
            done_reg       <= done_next;
            buf_reg        <= buf_next;
        end
    end

    // next, output
    always @(*) begin
        next_state      = current_state;
        b_tick_cnt_next = b_tick_cnt_reg;
        bit_cnt_next    = bit_cnt_reg;
        done_next       = done_reg;
        buf_next        = buf_reg;

        case (current_state)
            IDLE: begin
                done_next = 1'b0;
                b_tick_cnt_next = 5'b0;
                bit_cnt_next = 3'b0;
                if (b_tick & !rx) begin
                    next_state = START;
                end
            end
            START: begin
                if (b_tick)
                    if (b_tick_cnt_reg == 7) begin
                        b_tick_cnt_next = 0;
                        bit_cnt_next    = 0;
                        next_state = DATA;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
            end
            DATA: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        b_tick_cnt_next = 0;
                        buf_next = {rx, buf_reg[7:1]};
                        if (bit_cnt_reg == 7) begin
                            next_state = STOP;
                        end else begin
                            bit_cnt_next = bit_cnt_reg + 1;
                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end

                end
            end
            STOP: begin

                if (b_tick)
                    if (b_tick_cnt_reg == 15) begin
                        next_state = IDLE;
                        done_next  = 1'b1;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
            end

        endcase
    end




endmodule

module uart_tx (
    input        clk,
    input        reset,
    input        tx_start,
    input        b_tick,
    input  [7:0] tx_data,
    output       uart_tx,
    output       tx_busy,
    output       tx_done
);

    localparam [1:0] IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;


    // state reg
    reg [1:0] current_state, next_state;
    reg tx_reg, tx_next;
    //bit_cnt
    reg [2:0]
        bit_cnt_reg,
        bit_cnt_next; // 이전단계에서 next와 current형식으로 동작했기때문에 똑같이 

    reg [3:0] b_tick_cnt_reg, b_tick_cnt_next;  // 16배속한 tick검출 

    reg [7:0] data_in_buf_reg, data_in_buf_next;
    assign uart_tx = tx_reg;  //  for output CL=> SL
    //busy,done
    reg busy_reg, busy_next, done_reg, done_next;
    assign tx_busy = busy_reg;
    assign tx_done = done_reg;

    //state register SL
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            current_state   <= IDLE;
            tx_reg          <= 1'b1;
            bit_cnt_reg     <= 1'b0;
            b_tick_cnt_reg  <= 4'h0;
            busy_reg        <= 1'b0;
            done_reg        <= 1'b0;
            data_in_buf_reg <= 8'h00;

        end else begin
            current_state   <= next_state;
            tx_reg          <= tx_next;
            bit_cnt_reg     <= bit_cnt_next;
            b_tick_cnt_reg  <= b_tick_cnt_next;
            busy_reg        <= busy_next;
            done_reg        <= done_next;
            data_in_buf_reg <= data_in_buf_next;
        end
    end

    // next CL
    always @(*) begin
        next_state       = current_state;
        tx_next          = tx_reg;  // ratch발생예방
        bit_cnt_next     = bit_cnt_reg;
        busy_next        = busy_reg;
        done_next        = 1'b0;
        data_in_buf_next = data_in_buf_reg;
        b_tick_cnt_next  = b_tick_cnt_reg;
        case (current_state)
            IDLE: begin
                tx_next         = 1'b1;
                bit_cnt_next    = 1'b0;
                b_tick_cnt_next = 4'h0;
                busy_next       = 1'b0;
                done_next       = 1'b0;
                if (tx_start) begin
                    next_state       = START;
                    busy_next        = 1'b1;
                    data_in_buf_next = tx_data;
                end

            end
            START: begin
                // to start uart frame of start bit
                tx_next = 1'b0;
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        b_tick_cnt_next = 4'h0;
                        next_state = DATA;
                    end else begin

                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                tx_next = data_in_buf_reg[0];
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        if (bit_cnt_reg == 7) begin
                            b_tick_cnt_next = 4'h0;
                            next_state = STOP;
                        end else begin
                            b_tick_cnt_next = 4'h0;
                            bit_cnt_next = bit_cnt_reg + 1;
                            data_in_buf_next = {1'b0, data_in_buf_reg[7:1]};
                            next_state = DATA;
                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1;
                bit_cnt_next = 1'b0;
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin

                        done_next  = 1'b1;
                        next_state = IDLE;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule
//651개의 b_tick이 발생할때마다 baud틱 생성

module baud_tick (
    input      clk,
    input      reset,
    output reg b_tick
);
    parameter BAUDRATE = 9600 * 16;
    parameter F_count = 100_000_000 / BAUDRATE;
    reg [$clog2(F_count)-1:0] counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            b_tick <= 1'b0;
        end else begin
            if (counter_reg == (F_count - 1)) begin
                counter_reg <= 0;
                b_tick      <= 1'b1;
            end else begin
                counter_reg <= counter_reg + 1'b1;
                b_tick <= 1'b0;
            end
        end
    end
endmodule



