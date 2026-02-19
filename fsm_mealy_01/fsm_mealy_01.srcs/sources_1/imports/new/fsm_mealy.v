`timescale 1ns / 1ps

module fsm_mealy (

    input  clk,
    input  reset,
    input  din_bit,
    output dout_bit
);

    reg [1:0] state_reg, next_state;

    //parameter start = 3'b000;
    parameter S0 = 2'b00;
    parameter S1 = 2'b01;
    parameter S2 = 2'b10;
    parameter S3 = 2'b11;

    always @(state_reg or din_bit) begin

        case (state_reg)
            S0: begin
                if (din_bit == 1'b0) begin
                    next_state = S1;
                end else if (din_bit == 1'b1) begin
                    next_state = state_reg;
                end
            end

            S1: begin
                if (din_bit == 1'b1) begin
                    next_state = S2;
                end else if (din_bit == 1'b0) begin
                    next_state =state_reg;
                end
            end
            S2: begin
                if (din_bit == 1'b0) begin
                    next_state = S3;
                end else if (din_bit == 1'b1) begin
                    next_state = S0;
                end
            end

            S3: begin
                if (din_bit == 1'b0) begin
                    next_state = S1;
                end else if (din_bit == 1'b1) begin
                    next_state = S0;
                end
            end
            default: next_state = state_reg;

        endcase
    end

     always @(posedge clk, posedge reset) begin
        if (reset) begin
            state_reg <= S0;
        end else begin
            state_reg <= next_state;
        end
    end

    assign dout_bit = (state_reg == S3 && din_bit == 1'b1) ? 1 : 0;

endmodule
