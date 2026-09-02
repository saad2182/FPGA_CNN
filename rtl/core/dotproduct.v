`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    02:38:55 04/28/2018 
// Design Name: 
// Module Name:    dotproduct 
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
module dotproduct(
    input clk,rst,convfinaladd_done,
    input signed [7:0] temp_s,
	 input signed [7:0] temp_p,
	 output reg dotprod_done,
    output reg signed [15:0] conv_PS
    );
	// Temporary product and sum variable
	wire signed [15:0] prod_convfinal;
	reg signed  [15:0] sum_convfinal;
	
	initial begin
		sum_convfinal = 0;
		dotprod_done = 0;
	end
	
	assign prod_convfinal = temp_s*temp_p;
	
	always @ (posedge clk or posedge rst) begin
		if (rst) begin
				sum_convfinal=0;
				dotprod_done = 0;
				end
		else if (convfinaladd_done) begin
				conv_PS = sum_convfinal;
				sum_convfinal = 0;
				dotprod_done = 1;
				end
		else begin
				sum_convfinal = sum_convfinal  +  prod_convfinal;
				dotprod_done = 0;
			  end
	end
endmodule