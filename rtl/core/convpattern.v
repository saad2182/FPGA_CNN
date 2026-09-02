`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:49:52 04/26/2018 
// Design Name: 
// Module Name:    convpattern 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module convpattern(
    input clk,
	 input [7:0] row,
	 output signed [7:0] conv_p 
    );
    // Temp variable for storing matrix values
	 wire signed [3:0] temp_1;
	 wire signed [3:0] temp_2;
	 wire signed [3:0] temp_3;
	 wire signed [3:0] temp_4;
	 wire signed [3:0] temp_5;
	 wire signed [3:0] temp_6;
	 // Memory for storing pattern data
	 reg signed [3:0] mem [0:209];
	
	 initial begin
	 $readmemh("pattern_hex.txt",mem);	
	 end
	 
	 assign temp_1 = mem[row]; 
	 assign temp_2 = mem[row+2];
	 assign temp_3 = mem[row+15];
	 assign temp_4 = mem[row+17];
	 assign temp_5 = mem[row+30];
	 assign temp_6 = mem[row+32];
	 // Convolution with Sobel filter
	 assign conv_p = - (temp_1<<0) + (temp_2<<0) - (temp_3<<1) + (temp_4<<1) - (temp_5<<0) + (temp_6<<0);

endmodule
