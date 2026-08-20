// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module digital_clock_tb;

    //====================================================
    // Parameters
    //====================================================

    // Small value for simulation.
    // 10 system-clock cycles = 1 simulated second.
    parameter CLK_FREQ = 10;


    //====================================================
    // Testbench Signals
    //====================================================

    reg clk;
    reg rst;
    reg enable;

    reg       set_time;
    reg [4:0] set_hours;
    reg [5:0] set_minutes;
    reg [5:0] set_seconds;

    wire [4:0] hours;
    wire [5:0] minutes;
    wire [5:0] seconds;


    //====================================================
    // DUT
    //====================================================

    digital_clock #(
        .CLK_FREQ(CLK_FREQ)
    ) dut (

        .clk         (clk),
        .rst         (rst),
        .enable      (enable),

        .set_time    (set_time),
        .set_hours   (set_hours),
        .set_minutes (set_minutes),
        .set_seconds (set_seconds),

        .hours       (hours),
        .minutes     (minutes),
        .seconds     (seconds)

    );


    //====================================================
    // Clock Generation
    //====================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    //====================================================
    // Task: Display Current Time
    //====================================================

    task display_time;

        begin

            $display(
                "TIME = %02d:%02d:%02d",
                hours,
                minutes,
                seconds
            );

        end

    endtask


    //====================================================
    // Task: Set Time
    //====================================================

    task set_clock_time(
        input [4:0] h,
        input [5:0] m,
        input [5:0] s
    );

        begin

            set_hours   = h;
            set_minutes = m;
            set_seconds = s;

            set_time = 1'b1;

            @(posedge clk);

            #1;

            set_time = 1'b0;

        end

    endtask


    //====================================================
    // TEST SEQUENCE
    //====================================================

    initial begin

        //================================================
        // Initial Values
        //================================================

        rst         = 1'b1;
        enable      = 1'b0;

        set_time    = 1'b0;

        set_hours   = 5'd0;
        set_minutes = 6'd0;
        set_seconds = 6'd0;


        //================================================
        // TEST 1: RESET
        //================================================

        $display("--------------------------------------------");
        $display("TEST 1: RESET");
        $display("--------------------------------------------");

        #20;

        rst = 1'b0;

        #10;

        display_time();


        if ((hours == 0) &&
            (minutes == 0) &&
            (seconds == 0)) begin

            $display("TEST 1 PASSED");

        end

        else begin

            $display("TEST 1 FAILED");

        end


        //================================================
        // TEST 2: NORMAL CLOCK COUNTING
        //================================================

        $display("--------------------------------------------");
        $display("TEST 2: NORMAL COUNTING");
        $display("--------------------------------------------");

        enable = 1'b1;

        // Wait for several seconds
        repeat (5) begin

            repeat (CLK_FREQ) @(posedge clk);

            #1;

            display_time();

        end


        //================================================
        // TEST 3: DISABLE CLOCK
        //================================================

        $display("--------------------------------------------");
        $display("TEST 3: CLOCK DISABLE");
        $display("--------------------------------------------");

        enable = 1'b0;

        repeat (3) begin

            repeat (CLK_FREQ) @(posedge clk);

            #1;

            display_time();

        end

        $display("Clock should remain unchanged");


        //================================================
        // TEST 4: SET TIME
        //================================================

        $display("--------------------------------------------");
        $display("TEST 4: SET TIME");
        $display("--------------------------------------------");

        set_clock_time(
            5'd12,
            6'd34,
            6'd50
        );

        display_time();


        if ((hours == 12) &&
            (minutes == 34) &&
            (seconds == 50)) begin

            $display("TEST 4 PASSED");

        end

        else begin

            $display("TEST 4 FAILED");

        end


        //================================================
        // TEST 5: SECOND ROLLOVER
        //================================================

        $display("--------------------------------------------");
        $display("TEST 5: SECOND ROLLOVER");
        $display("--------------------------------------------");

        enable = 1'b1;

        repeat (10) @(posedge clk);

        #1;

        display_time();


        //================================================
        // TEST 6: MINUTE ROLLOVER
        //================================================

        $display("--------------------------------------------");
        $display("TEST 6: MINUTE ROLLOVER");
        $display("--------------------------------------------");

        set_clock_time(
            5'd12,
            6'd59,
            6'd59
        );

        display_time();

        // One second
        repeat (CLK_FREQ) @(posedge clk);

        #1;

        display_time();


        if ((hours == 12) &&
            (minutes == 0) &&
            (seconds == 0)) begin

            $display("TEST 6 PASSED");

        end

        else begin

            $display("TEST 6 FAILED");

        end


        //================================================
        // TEST 7: HOUR ROLLOVER
        //================================================

        $display("--------------------------------------------");
        $display("TEST 7: HOUR ROLLOVER");
        $display("--------------------------------------------");

        set_clock_time(
            5'd23,
            6'd59,
            6'd59
        );

        display_time();

        // One second
        repeat (CLK_FREQ) @(posedge clk);

        #1;

        display_time();


        if ((hours == 0) &&
            (minutes == 0) &&
            (seconds == 0)) begin

            $display("TEST 7 PASSED");

        end

        else begin

            $display("TEST 7 FAILED");

        end


        //================================================
        // END SIMULATION
        //================================================

        $display("--------------------------------------------");
        $display("SIMULATION COMPLETED");
        $display("--------------------------------------------");

        #20;

        $finish;

    end


    //====================================================
    // Monitor
    //====================================================

    initial begin

        $monitor(
            "TIME=%0t | RESET=%b | ENABLE=%b | CLOCK=%02d:%02d:%02d",
            $time,
            rst,
            enable,
            hours,
            minutes,
            seconds
        );

    end


    //====================================================
    // Waveform Generation
    //====================================================

    initial begin

        $dumpfile("digital_clock.vcd");

        $dumpvars(0, digital_clock_tb);

    end

endmodule
