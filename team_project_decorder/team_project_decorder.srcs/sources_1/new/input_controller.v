`timescale 1ns / 1ps

module priority_controller (
    input clk,
    input reset,

    input [2:0] i_sw,
    input i_btn_r,
    input i_btn_l,
    input i_btn_u,
    input i_btn_d,

    output reg o_btn_r,
    output reg o_btn_l,
    output reg o_btn_u,
    output reg o_btn_d,
    output reg o_sw_0,
    output reg o_sw_1,
    output reg o_sw_2
);

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            o_btn_r <= 1'b0;
            o_btn_l <= 1'b0;
            o_btn_u <= 1'b0;
            o_btn_d <= 1'b0;
            o_sw_0  <= 1'b0;
            o_sw_1  <= 1'b0;
            o_sw_2  <= 1'b0;
        end else begin
            o_btn_r <= 1'b0;
            o_btn_l <= 1'b0;
            o_btn_u <= 1'b0;
            o_btn_d <= 1'b0;
            o_sw_0  <= 1'b0;
            o_sw_1  <= 1'b0;
            o_sw_2  <= 1'b0;

            if (i_sw[2]) begin
                o_sw_2 <= 1'b1;
            end else if (i_sw[1]) begin
                o_sw_1 <= 1'b1;
            end else if (i_sw[0]) begin
                o_sw_0 <= 1'b1;
            end else if (i_btn_r) begin
                o_btn_r <= 1'b1;
            end else if (i_btn_l) begin
                o_btn_l <= 1'b1;
            end else if (i_btn_d) begin
                o_btn_d <= 1'b1;
            end else if (i_btn_u) begin
                o_btn_u <= 1'b1;
            end
        end
    end

endmodule
