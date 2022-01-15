`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/05/2021 09:29:59 AM
// Design Name: 
// Module Name: clock_div
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// COUNT_VAL divides the 100MHz system clock
// ex. COUNT_VAL = 4, 100/4 = 25MHz
module clock_div  #(
	parameter int COUNT_VAL = 1)(
    input logic clock,
    input logic reset,
    output logic div_clock
    );
    
logic [$clog2(COUNT_VAL):0] count;


localparam COUNT_VAL_n = COUNT_VAL / 2;

always_ff @(posedge clock or posedge reset)
    begin
        if(reset) begin
           count <= 'b0;
           div_clock <= 'b0;
         end
         else if (count == COUNT_VAL_n -1) begin
           count <= 'b0;
           div_clock <= ~div_clock;
         end
         else begin
           count <= count +1;
           div_clock <= div_clock; 
         end
    end
         
endmodule
