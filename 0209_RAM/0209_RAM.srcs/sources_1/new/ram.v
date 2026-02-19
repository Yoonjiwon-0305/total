`timescale 1ns / 1ps

module ram (

    input            clk,
    input            we,
    input      [9:0] addr,   // adder= address
    input      [7:0] wdata,
    output reg [7:0] rdata

);

    // ram space
    reg [7:0] ram[0:1023];  // 벡터 표현 // 2^10 의 공간 필요

    // to write to ram
    //always @(posedge clk) begin
    //    if (we) begin
    //        ram[addr] <= wdata;
    //    end
    //
    //end

    // 조합출력 // read
    //assign rdata = ram[addr];

    // 순차출력 // read 
    // 상승엣지 가 0이고 wr이 0일때 
    always @(posedge clk) begin
        if (we) begin
            ram[addr] <= wdata;

        end else begin
            rdata <= ram[addr];

        end
    end

endmodule
