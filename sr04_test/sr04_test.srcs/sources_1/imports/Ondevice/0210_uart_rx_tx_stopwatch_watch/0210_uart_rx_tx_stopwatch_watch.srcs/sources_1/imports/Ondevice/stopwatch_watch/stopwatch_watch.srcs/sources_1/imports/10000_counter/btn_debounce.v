`timescale 1ns / 1ps

module btn_debounce (

    input  clk,
    input  reset,
    input  i_btn,
    output o_btn

);
    // clock divider for debounce shift register
    // 100M hz=> 100khz
    // counter => 100M/100k =1000 count 필요
    parameter CLK_DIV = 1000;
    parameter F_COUNT = 100_000_000 / CLK_DIV;  //CLk DIV
    reg [$clog2(F_COUNT)-1:0] counter_reg;
    reg clk_100khz_reg;

    always @(posedge clk, posedge reset) begin
        if (reset)begin
            counter_reg <= 0;
            clk_100khz_reg<=1'b0;
        end else begin
            counter_reg <= counter_reg +1;
            if (counter_reg == F_COUNT-1) begin
                counter_reg <=0;
                clk_100khz_reg <=1'b1;
            end else begin
            
                clk_100khz_reg<=1'b0;
            end
        end
    end

    // series 8 tap F/F 
    //reg [7:0] debounce_reg;
    reg [7:0] q_reg, q_next;
    wire debounce;

    //SL순차논리
    always @(posedge clk_100khz_reg, posedge reset) begin
        if (reset) begin
            q_reg <= 0;
        end else begin
            // 레지스터 만들어야함
            //debounce_reg <= {i_btn,debounce_reg[7:1]}
            q_reg <= q_next;
        end

    end
    // next CL 조합논리
    always @(*) begin
        q_next = {i_btn, q_reg[7:1]};
    end

    // AND연산 하는 부분 생성
    // decounce siginal 생성 => 8input AND
    assign debounce = &q_reg;

    reg edge_reg;
    //edge detection 
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            edge_reg <= 1'b0;
        end else begin
            edge_reg <= debounce;
        end

    end
// and 로직 연산
    assign o_btn = debounce & (~edge_reg);
endmodule
