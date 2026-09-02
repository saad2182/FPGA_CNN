`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:51:23 04/30/2018
// Design Name:   convpattern
// Module Name:   convpattern_tb.v
// Project Name:  Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: convpattern
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module convpattern_tb;

	// Inputs
	reg clk;
	reg [7:0] row;

	// Outputs
	wire [7:0] conv_p;

	// Instantiate the Unit Under Test (UUT)
	convpattern uut (
		.clk(clk), 
		.row(row), 
		.conv_p(conv_p)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		row = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		for (row = 0;row < 210;row = row + 1) begin
			$display("%d",conv_p);
			#20;
			end
	end
      
endmodule

