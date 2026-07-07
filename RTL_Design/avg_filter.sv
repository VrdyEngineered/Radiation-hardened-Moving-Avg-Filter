//================================================================
// Module      : Moving Average Filter
// Project     : Satellite Thermal Monitor
// Description : 4-point moving average filter for ADC noise
//               reduction on satellite temperature sensor input
// Author      : Chilla vivek Reddy
// Date        : 2026-06-18
// Version     : 1.0
//================================================================
`timescale 1ns/1ps

module moving_avg_filter #(
    parameter DATA_WIDTH = 16 , 
    parameter FILTER_LEN = 4)(
        input  logic                   clk,
        input  logic                   rst_n,
        input  logic                   valid_in,
        input  logic [DATA_WIDTH-1:0]  sample_in,
        output logic [DATA_WIDTH-1:0]  avg_out,
        output logic                   valid_out  
);
    //----------------------------------------------------------
    // Internal Signals
    //----------------------------------------------------------

    // Sample storage — shift register array
    logic [DATA_WIDTH-1:0] shift_reg [0:FILTER_LEN-1];

    // Accumulator — 18 bits to hold max sum without overflow
    // Max value: 4 x 65535 = 262140 → requires 18 bits
    logic [17:0] acc;  

    // Valid tracking — counts samples until filter is full
    logic [$clog2(FILTER_LEN):0] fill_cnt;

    //----------------------------------------------------------
    // Sequential Logic
    //----------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fill_cnt <= '0;
            for (int i=0 ;i<FILTER_LEN; i++) begin
                shift_reg[i] <= '0;
            end
        end
        else if (valid_in) begin
            for (int i=FILTER_LEN-1; i>0; i--) begin
                shift_reg[i] <= shift_reg[i-1];
            end
            shift_reg[0] <= sample_in;
            if (fill_cnt < $unsigned(FILTER_LEN)) begin
                fill_cnt <= fill_cnt + 1'b1;
            end
        end
    end

    //----------------------------------------------------------
    // Combinational Logic - Accumulator
    //----------------------------------------------------------
    always_comb begin
        acc = '0;
        for (int i=0; i<FILTER_LEN; i++) begin
            acc += shift_reg[i];        
        end
    end

    //----------------------------------------------------------
    // Combinational Logic - Average Calculation & valid output
    //----------------------------------------------------------
    // always_comb begin
    //     if (fill_cnt == $unsigned(FILTER_LEN)) begin
    //         avg_out = acc[17:2];
    //         valid_out = 1'b1;
    //     end
    //     else begin
    //         avg_out = '0;
    //         valid_out = 1'b0;
    //     end
    // end
    //----------------------------------------------------------
    // Output Logic
    //----------------------------------------------------------
    assign valid_out = (fill_cnt == FILTER_LEN) ? 1'b1 : 1'b0;
    assign avg_out   = (fill_cnt == FILTER_LEN) ? acc[17:2] : '0;


endmodule
