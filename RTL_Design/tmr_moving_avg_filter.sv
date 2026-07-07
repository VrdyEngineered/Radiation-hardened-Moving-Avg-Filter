//================================================================
// Module      : Triple Modular Redundancy based Moving Average Filter
// Project     : Satellite Thermal Monitor
// Description : 4-point moving average filter for ADC noise
//               reduction on satellite temperature sensor input along with TMR and majority voting to improve reliability
// Author      : Chilla vivek Reddy
// Date        : 2026-07-04
// Version     : 2.0
//================================================================
`timescale 1ns/1ps

//Radiation Hardened Triple Modular Redundancy based Moving Average Filter
module tmr_moving_avg_filter #(
    parameter DATA_WIDTH = 16 , 
    parameter FILTER_LEN = 4)(
        input  logic                   clk,
        input  logic                   rst_n,
        input  logic                   valid_in,
        input  logic [DATA_WIDTH-1:0]  sample_in,
        output logic [DATA_WIDTH-1:0]  avg_out,
        output logic                   valid_out,
        output logic                   seu_detected   // seu = single event upset (bit flip error due to cosmic rays or radiation)
);
    //----------------------------------------------------------
    // Internal Signals — Filter Outputs to Voter
    //----------------------------------------------------------

    // Three filter outputs
    logic [DATA_WIDTH-1:0] avg_out_a;
    logic [DATA_WIDTH-1:0] avg_out_b;
    logic [DATA_WIDTH-1:0] avg_out_c;

    // Three valid outputs
    logic                  valid_out_a;
    logic                  valid_out_b;
    logic                  valid_out_c;

    //----------------------------------------------------------
    // Filter Instantiations — Three identical copies
    //----------------------------------------------------------

    moving_avg_filter #(
        .DATA_WIDTH (DATA_WIDTH),
        .FILTER_LEN (FILTER_LEN)
    ) filter_a (
        .clk       (clk),
        .rst_n     (rst_n),
        .valid_in  (valid_in),
        .sample_in (sample_in),
        .avg_out   (avg_out_a),
        .valid_out (valid_out_a)
    );

    moving_avg_filter #(
        .DATA_WIDTH (DATA_WIDTH),
        .FILTER_LEN (FILTER_LEN)
    ) filter_b (
        .clk       (clk),
        .rst_n     (rst_n),
        .valid_in  (valid_in),
        .sample_in (sample_in),
        .avg_out   (avg_out_b),
        .valid_out (valid_out_b)
    );

    moving_avg_filter #(
        .DATA_WIDTH (DATA_WIDTH),
        .FILTER_LEN (FILTER_LEN)
    ) filter_c (
        .clk       (clk),
        .rst_n     (rst_n),
        .valid_in  (valid_in),
        .sample_in (sample_in),
        .avg_out   (avg_out_c),
        .valid_out (valid_out_c)
    );

    //----------------------------------------------------------
    // Majority Voter Instantiation
    //----------------------------------------------------------
    majority_voter #(
        .DATA_WIDTH (DATA_WIDTH)
    ) voter (
        .in_a      (avg_out_a),
        .in_b      (avg_out_b),
        .in_c      (avg_out_c),
        .voted_out (avg_out),
        .seu_detected (seu_detected)
    );

    //----------------------------------------------------------
    // Valid Output — Bitwise majority of three valid signals
    //----------------------------------------------------------
    assign valid_out = (valid_out_a & valid_out_b) |
                       (valid_out_a & valid_out_c) |
                       (valid_out_b & valid_out_c);



endmodule
