//===========================================================
// module    : tb_moving_avg_filter
// project   : Satellite Thermal Monitor
// Description : Testbench for 4-point moving average filter
// Author    : Chilla vivek Reddy
// Date      : 2026-07-06
// Version   : 2.0
//===========================================================

`timescale 1ns/1ps

module tb_moving_avg_filter;
        //----------------------------------------------------------
        // Testbench Parameters
        //----------------------------------------------------------
        localparam CLK_PERIOD = 10;
        localparam DATA_WIDTH = 16;
        localparam FILTER_LEN = 4;

       //---------------------------------------------------------------
       // DUT signal declarations
       //---------------------------------------------------------------
       logic clk;
       logic rst_n;
       logic valid_in;
       logic [DATA_WIDTH-1:0] sample_in;
       logic [DATA_WIDTH-1:0] avg_out;
       logic valid_out;
       logic seu_detected;

       //---------------------------------------------------------------
       // DUT instantiation 
       //---------------------------------------------------------------
       tmr_moving_avg_filter #(
          .DATA_WIDTH (DATA_WIDTH),
          .FILTER_LEN (FILTER_LEN)
       ) dut (
           .clk       (clk),
           .rst_n     (rst_n),
           .valid_in  (valid_in),
           .sample_in (sample_in),
           .avg_out   (avg_out),
           .valid_out (valid_out),
           .seu_detected (seu_detected)
       );

       //---------------------------------------------------------------
       // Clock Generation
       //---------------------------------------------------------------
       initial clk = 0;
       always #(CLK_PERIOD/2) clk = ~clk;

       //---------------------------------------------------------------
       // Main Test Sequence
       //---------------------------------------------------------------
       initial begin
        // initialize inputs
        rst_n     =  0;
        valid_in  =  0;
        sample_in = '0;

        // Hold reset for 4 clk cycles
        repeat(4) @(posedge clk);
        rst_n = 1;

        // Small delay after reset release
        repeat(2) @(posedge clk);

        //----------------------------------------------------------
        // Test Case 1 — Send 4 known samples, check average
        // Input: 100, 200, 300, 400
        // Expected average: (100+200+300+400)/4 = 250
        //----------------------------------------------------------
        valid_in = 1;

        sample_in = 16'd100; @(posedge clk);
        sample_in = 16'd200; @(posedge clk);
        sample_in = 16'd300; @(posedge clk);
        sample_in = 16'd400; @(posedge clk);

        // Drop valid, wait and observe output
        valid_in  = 0;
        sample_in = '0;
        repeat(2) @(posedge clk);

        $display("TC1: avg_out=%0d (expected 250)",   avg_out);

        //----------------------------------------------------------
        // Test Case 2 — All zeros
        // Expected avg_out : 0
        //----------------------------------------------------------
        valid_in = 1;
        sample_in = 16'd0; @(posedge clk);
        sample_in = 16'd0; @(posedge clk);
        sample_in = 16'd0; @(posedge clk);
        sample_in = 16'd0; @(posedge clk);
        valid_in  = 0;
        repeat(2) @(posedge clk);
        
        $display("TC2: avg_out=%0d (expected 0)",   avg_out);

        //----------------------------------------------------------
        // Test Case 3 — Maximum values
        // Input : 65535 x 4
        // Expected avg_out : 65535
        //----------------------------------------------------------
        valid_in = 1;
        sample_in = 16'hFFFF; @(posedge clk);
        sample_in = 16'hFFFF; @(posedge clk);
        sample_in = 16'hFFFF; @(posedge clk);
        sample_in = 16'hFFFF; @(posedge clk);
        valid_in  = 0;
        repeat(2) @(posedge clk);

        $display("TC3: avg_out=%0d (expected 65535)",   avg_out);

        //----------------------------------------------------------
        // Test Case 4 — Alternating values
        // Input : 0, 65535, 0, 65535
        // Expected avg_out : 32767
        //----------------------------------------------------------
        valid_in = 1;
        sample_in = 16'd0;     @(posedge clk);
        sample_in = 16'hFFFF;  @(posedge clk);
        sample_in = 16'd0;     @(posedge clk);
        sample_in = 16'hFFFF;  @(posedge clk);
        valid_in  = 0;
        repeat(2) @(posedge clk);

        $display("TC4: avg_out=%0d (expected 32767)",   avg_out);

        //----------------------------------------------------------
        // Test Case 5 — SEU Fault Injection on Filter A
        // Corrupt avg_out_a mid-simulation
        // Expected: voter still outputs 250 using B and C
        //----------------------------------------------------------
        valid_in = 1;
        sample_in = 16'd100; @(posedge clk);
        sample_in = 16'd200; @(posedge clk);
        sample_in = 16'd300; @(posedge clk);
        sample_in = 16'd400; @(posedge clk);
        valid_in  = 0;

        // Wait for output to settle
        repeat(2) @(posedge clk);

        // Inject fault — corrupt filter_a output
        force dut.avg_out_a = 16'hDEAD;
        repeat(2) @(posedge clk);

        $display("TC5 SEU inject: avg_out=%0d (expected 250)", avg_out);

        // Release fault
        release dut.avg_out_a;
        repeat(2) @(posedge clk);

        //----------------------------------------------------------
        // TC6 — Two copies corrupted, seu_detected should assert
        //----------------------------------------------------------
        force dut.avg_out_a = 16'hDEAD;
        force dut.avg_out_b = 16'hBEEF;
        repeat(2) @(posedge clk);
        $display("TC6 two upsets: seu_detected=%0b (expected 1)", seu_detected);
        release dut.avg_out_a;
        release dut.avg_out_b;
        repeat(2) @(posedge clk);


        $finish;

       end

       //---------------------------------------------------------------
       // VCD Dump — for GTKWave
       //---------------------------------------------------------------
       initial begin
           $dumpfile("dump.vcd");
           $dumpvars(0, tb_moving_avg_filter);
       end

       //---------------------------------------------------------------
       // Simulation End
       //---------------------------------------------------------------
       initial begin
           #10000;
           $display("TIMEOUT: Simulation ended at %0t", $time);
           $finish;
       end

endmodule
