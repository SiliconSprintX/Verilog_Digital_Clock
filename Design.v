// Code your design here
`timescale 1ns/1ps

module digital_clock #(
    parameter CLK_FREQ = 10
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       enable,

    // Time setting inputs
    input  wire       set_time,
    input  wire [4:0] set_hours,
    input  wire [5:0] set_minutes,
    input  wire [5:0] set_seconds,

    // Current time outputs
    output reg  [4:0] hours,
    output reg  [5:0] minutes,
    output reg  [5:0] seconds
);

    //====================================================
    // 1 Hz Clock Divider
    //====================================================

    reg [31:0] clk_count;

    //====================================================
    // Clock Divider + Digital Clock
    //====================================================

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            clk_count <= 32'd0;

            hours     <= 5'd0;
            minutes   <= 6'd0;
            seconds   <= 6'd0;

        end

        else begin

            //================================================
            // Set Time
            //================================================

            if (set_time) begin

                hours   <= set_hours;
                minutes <= set_minutes;
                seconds <= set_seconds;

                clk_count <= 32'd0;

            end

            //================================================
            // Normal Clock Operation
            //================================================

            else if (enable) begin

                // Generate 1 Hz tick
                if (clk_count == CLK_FREQ - 1) begin

                    clk_count <= 32'd0;

                    //========================================
                    // Seconds
                    //========================================

                    if (seconds == 6'd59) begin

                        seconds <= 6'd0;

                        //====================================
                        // Minutes
                        //====================================

                        if (minutes == 6'd59) begin

                            minutes <= 6'd0;

                            //================================
                            // Hours
                            //================================

                            if (hours == 5'd23) begin
                                hours <= 5'd0;
                            end

                            else begin
                                hours <= hours + 1'b1;
                            end

                        end

                        else begin
                            minutes <= minutes + 1'b1;
                        end

                    end

                    else begin
                        seconds <= seconds + 1'b1;
                    end

                end

                else begin
                    clk_count <= clk_count + 1'b1;
                end

            end

            else begin

                // Clock disabled
                clk_count <= clk_count;

            end

        end

    end

endmodule
