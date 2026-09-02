`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:04:26 04/30/2018
// Design Name:   convsample
// Module Name:   convsample_tb.v
// Project Name:  Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: convsample
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module convsample_tb;

	// Inputs
	reg clk;
	reg [15:0] row;
	
	reg signed [7:0] mem [0:37399];

	// Outputs
	wire [7:0] conv_s;

	// Instantiate the Unit Under Test (UUT)
	convsample uut (
		.clk(clk), 
		.row(row), 
		.conv_s(conv_s)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		row = 0;

		// Wait 100 ns for global reset to finish
		#10;
        
		// Add stimulus here
		for (row = 0;row < 37400;row = row + 1) begin
			//$display("%d %d",conv_s,row);
			mem[row] = conv_s;
			#1;
		end
	end
      
endmodule

