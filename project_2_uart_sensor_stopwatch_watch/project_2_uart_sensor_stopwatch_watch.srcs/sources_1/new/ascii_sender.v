`timescale 1ns / 1ps

module ascii_sender (
    input [23:0] watch_data,
    input [23:0] stopwatch_data,
    input [8:0]  sensor_9bit,
    input [1:0]  sel,         
    input [2:0]  digit_sel,   
    output reg [7:0] out_8bit 
);

    wire [23:0] formatted_sensor;
    reg [23:0] selected_data;

    assign formatted_sensor = {12'd0, (sensor_9bit/100)%10, (sensor_9bit/10)%10, sensor_9bit%10};

    always @(*) begin
        case(sel)
            2'b00: selected_data = watch_data;
            2'b01: selected_data = stopwatch_data;
            2'b10: selected_data = formatted_sensor;
            default: selected_data = 24'd0;
        endcase
    end

    always @(*) begin
        case(digit_sel)
            3'd0: out_8bit = {4'b1110, selected_data[3:0]};   
            3'd1: out_8bit = {4'b1101, selected_data[7:4]};   
            3'd2: out_8bit = {4'b1011, selected_data[11:8]};  
            3'd3: out_8bit = {4'b0111, selected_data[15:12]}; 
            default: out_8bit = 8'hFF;
        endcase
    end

endmodule