//================================================================
// Module      : Majority Voter
// Project     : Satellite Thermal Monitor
// Description : used for voting the output of 3 moving average filters to reduce noise and improve reliability   
// Author      : Chilla vivek Reddy
// Date        : 2026-07-04
// Version     : 1.0
//================================================================

`timescale 1ns/1ps

module majority_voter #(
    parameter DATA_WIDTH = 16)(
    input  logic [DATA_WIDTH-1:0] in_a,
    input  logic [DATA_WIDTH-1:0] in_b,
    input  logic [DATA_WIDTH-1:0] in_c,
    output logic [DATA_WIDTH-1:0] voted_out,
    output logic seu_detected   
);
    //----------------------------------------------------------
    // Combinational Logic — Word-level Majority Voter
    //----------------------------------------------------------
    always_comb begin
        if(in_a == in_b)
            voted_out = in_a;
        else if (in_a == in_c)
            voted_out = in_a;
        else if (in_b == in_c)
            voted_out = in_b;
        else
            voted_out = in_a; // Default case, can be modified as per requirement
    end

    //----------------------------------------------------------
    // Combinational Logic — SEU Detection
    //----------------------------------------------------------
    assign seu_detected = (in_a != in_b) & 
                      (in_a != in_c) & 
                      (in_b != in_c);


endmodule
