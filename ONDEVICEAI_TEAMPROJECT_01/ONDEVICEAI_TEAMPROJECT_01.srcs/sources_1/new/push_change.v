`timescale 1ns / 1ps

module push_change (
    input      clk,
    input      rst,
    input      d_in,
    input      push,
    output reg d_out
);

    reg d1, d2;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            d1 <= 1'b0;
            d2 <= 1'b0;
        end else begin
            d1 <= d_in;
            d2 <= d1;
        end
    end


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            d_out <= d_in;
        end else begin
            if (push) begin
                d_out = ~d_out;
            end else begin
                if (d1 != d2) begin
                    d_out = d_in;
                end
            end
        end
    end

endmodule