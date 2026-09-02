`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:21:14 04/30/2018 
// Design Name: 
// Module Name:    top 
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
module top(input clk,rst,output vsync,hsync,vfree,hfree, output reg [3:0] r,g,b);//output reg out,done);
	
	reg [3:0] finals_row,finals_col,free,detect_out;
	reg [7:0] p_row,convp_row,finalp_row,detect_row,detect_col;
	reg signed [7:0] temp_s,temp_p;
	reg [15:0] stride,finalconv_add,convfin_row,pat_detect_row,detect_addr,convs_row,s_row;
    reg signed [15:0] temp_maxpool,max,maxpool_out;
	
	// Step parameters
	parameter [2:0] step1=3'b000, step2=3'b001, step3=3'b010, step4=3'b011,step5=3'b100;
	reg [2:0] current_state,next_state;

	//Control Signals
	reg convp_done, convs_done, convfinaladd_done, convfinal_done,maxpool_done,pattern_en,convpmem_en,convpmem_wr,sample_en,convsmem_en,convsmem_wr,finalconv_en,maxpool_en,convfinalmem_wr
	,pat_detect_en,pat_detect_done,detect_mem_wr,detectcount_en,convp_en,convs_en;
	
	wire signed [15:0] convpatternsample_out,maxpool_value;
	reg dotprod_done;
	wire dotprod_done_temp;
	wire signed [7:0] convp_temp;
    wire signed [7:0] convs_temp; 
    wire vgaclk;
    wire [10:0] x,y;
	wire [15:0] detect_temp,temp_finalconv_add;
	
    // Memories
	reg signed [7:0] convp_mem [0:155];    // Memory to store convoluted pattern
    reg signed [7:0] convs_mem [0:36623];  // Memory to store convoluted sample
    reg signed [15:0] convfinal_mem [0:32341]; // Memory to store final convoluted values
    reg detect_mem [0:32341]; // Memory to store detected patterns (0 or 1)
	
	// Instantiations
	convsample sampleconvolution ( .clk(clk),.row(s_row),.conv_s(convs_temp));
	convpattern patternconvolution ( .clk(clk),.row(p_row),.conv_p(convp_temp));
	dotproduct finalconvolution (.clk(clk),.rst(rst),.convfinaladd_done(convfinaladd_done),.temp_s(temp_s),.temp_p(temp_p),.dotprod_done (dotprod_done_temp),.conv_PS(convpatternsample_out));	
	// vga port supports 25Mhz clock, that's why we are using clockDiv module 
    clockDiv pixel(.clk(clk),.div(32'd1),.out(vgaclk));
    // Instantiating with provided vgapulse module to get horizontal sync pulse and position for the display
    vgapulse Horizontal(.clk(vgaclk),.stage1(22'd96),.stage2(22'd144),.stage3(22'd784),.endStage(22'd800),.syncPulse(hsync),.free(hfree),.position(x));
    // Instantiating with provided vgapulse module to get vertical sync pulse and position for the display
    vgapulse Vertical(.clk(hsync),.stage1(22'd2),.stage2(22'd35),.stage3(22'd515),.endStage(22'd525),.syncPulse(vsync),.free(vfree),.position(y));
	
	initial begin
		convp_done = 0;
		convs_done = 0;
		convfinaladd_done = 0;
		convfinal_done = 0;
		pat_detect_done = 0;
		maxpool_done = 0;
		//done = 0;

	end
	
	// Counter for pattern data indexing	
	always @ (posedge clk or posedge rst) 
	begin
		if (rst==1)
			p_row<=0; 
		else if (pattern_en) begin 
			if (p_row+32==209)
				p_row<=0;
			else 
				p_row<=p_row+1;
		end
	end
	
	// Counter for sample data indexing	
	always @ (posedge clk or posedge rst) 
    begin
        if (rst==1)
            s_row<=0; 
        else if(sample_en) begin 
            if (s_row+442==37399)
                s_row<=0;
            else 
                s_row<=s_row+1;
        end
    end
        
	// Counter for convoluted pattern data indexing
	always @ (posedge clk or posedge rst)
	begin
		if (rst==1)
			convp_row<=0; 
		else if (convpmem_en) begin 
			if (convp_row==155)begin
				convp_row<=0;
				convp_done<=1;
			end
			else 
				convp_row<=convp_row+1;
		end
	end
	
	// Storing connvoluted pattern image
	always @ (posedge clk) begin		
		if (convpmem_wr)
		convp_mem [convp_row]<=convp_temp;
	end
	
	// Counter for convoluted sample data indexing	
	always @ (posedge clk or posedge rst) 
	begin
		if (rst==1)
			convs_row<=0; 
		else if (convsmem_en) begin 
			if (convs_row==36623)begin
				convs_row<=0;
				convs_done<=1;
			end
			else 
				convs_row<=convs_row+1;
		end
	end
	// Storing connvoluted sample image
	always @ (posedge clk) begin
		if(convsmem_wr)
		convs_mem [convs_row]<=convs_temp;
	end
	
	// Final Convolution
	
	// Counter for final convolution 
	always @ (posedge clk or posedge rst) 
	begin
		if (rst==1)
			finalp_row<=0;
		else if (convp_en) begin
			if (finalp_row==155)
			finalp_row<=0;	
			else
			finalp_row<=finalp_row+1;
		end
	end
	
	assign temp_finalconv_add = stride + finals_row + 218*finals_col;
	
	
	// Generating address and stride for final convolution
	always @ (posedge clk or posedge rst) 
	begin
		if (rst==1) begin
			finals_row<=0;
			finals_col<=0;
			stride<=0;
			end
		else if (convs_en) begin
				if (finals_row==12 && finals_col<11) begin
					finals_row<=0;
					finals_col<=finals_col+1;
				end
				else if (stride>32341) begin
						stride<=0;
						finals_row <= 0;
						finals_col <= 0;
				end
				else if (finals_row==12 && finals_col==11)	begin
					stride<=stride+1;
					finals_col<=0;
					finals_row<=0;
					convfinaladd_done<=1;
				end
				else begin
					finals_row <= finals_row + 1;
					convfinaladd_done<=0;
				end
		end
	end
	
	// Final address 
	always @ (posedge clk)	finalconv_add <= temp_finalconv_add; 
	
	always @(*) 
	begin
		temp_s=convs_mem[finalconv_add];
		temp_p=convp_mem[finalp_row];
	end
		
	always @ (posedge clk) begin
		dotprod_done <= dotprod_done_temp;
	end
	
	// Counter for convfinal memory indexing
	always @ (posedge clk or posedge rst) 
	begin
		if (rst==1) begin
			convfin_row <=0;
			end
		else if (finalconv_en) begin  
			if (dotprod_done)begin
				if (convfin_row == 32341)begin
					convfin_row <=0;
					convfinal_done<=1;
				end
				else
					convfin_row <= convfin_row + 1;
			end
		end
	end

	// Maxpooling kernel
	always @ (posedge clk or posedge rst) begin
		if (rst) 
			max <= 0;
		else if (temp_maxpool>max)
			max <= temp_maxpool;
	end
	// Multiplying by the threshold = 0.8
	//assign maxpool_value=(max>>1)+(max>>2)+(max>>4);
	assign maxpool_value=(max>>1)+(max>>2)+(max>>3)+(max>>4) + (max>>9);
	
	always @(posedge clk)begin
		if (maxpool_en) begin
		maxpool_out<=maxpool_value;
		maxpool_done<=1;
		end
	end
	// Storing max value in memory
	always @ (posedge clk) begin
		if (convfinalmem_wr) begin
			convfinal_mem [convfin_row]<=convpatternsample_out;
			temp_maxpool <= convpatternsample_out;
		end
	end
	
	// Counter for pattern detection
	always @ (posedge clk or posedge rst) 
	begin
		if (rst==1)
			pat_detect_row <=0;
		else if (pat_detect_en) begin
				if (pat_detect_row == 32341)begin
					pat_detect_row <=0;
					pat_detect_done<=1; 
				end
				else
					pat_detect_row <= pat_detect_row + 1;
		end
	end	
	
	// Storing detected pattern into convfinal memory 
	always @ (posedge clk) begin			 
		if (detect_mem_wr) begin
			if (convfinal_mem[pat_detect_row]<maxpool_out) begin
				detect_mem [pat_detect_row] <= 1;
			end
			else begin
				detect_mem [pat_detect_row] <= 0;
			end
		end
	end
	
	assign detect_temp = detect_col + 157*detect_row;
	
		always @ (posedge vgaclk) begin
		     if (rst) begin
		         detect_row<=0;
                 detect_col<=0;
		      end
		else if (detectcount_en) begin
            if ((x==101+detect_row)&&(y==101+detect_col)&&(detect_col == 156) && (detect_row<205)) begin
                detect_col<=0;
                detect_row<=detect_row+1;
            end
			//if (detect_col == 156 && detect_row<205) begin
				//detect_col<=0;
				//detect_row<=detect_row+1;
			else if ((x==101+detect_row)&&(y==101+detect_col)) begin
                    detect_col<=detect_col+1;
                end
			else if (detect_col == 156 && detect_row == 205) begin
				detect_col<=0;
				detect_row<=0;
				//done <= 1;
			end
			//else begin
				//detect_col<=detect_col+1;
			//end
            end
	end
	
		always @ (posedge vgaclk) begin
		detect_addr <= detect_temp;
	end
	
//	always @(*) 
//	begin
//	   if (detect_addr == 32341) begin
//	       /done = 1;
//	       out=detect_mem[detect_addr];
//	   end
//	   else
//	       out=detect_mem[detect_addr];
//	end

	always @(*) begin
	   detect_out={4{detect_mem[detect_addr]}};
	end
	
	always @ (*) begin
	   free[0]=hfree&&vfree&&(x<257)&&(x>100)&&(y<306)&&(y>100);				// value of 'x' and 'hfree' obtained from vgaPulse Horizontal
	   //free[1]=hfree&&vfree&&(x<306)&&(x>100)&&(y<257)&&(y>100);				// value of 'y' and 'vfree' obtained from vgaPulse Vertical
	  // free[2]=hfree&&vfree&&(x<306)&&(x>100)&&(y<257)&&(y>100);
	  // free[3]=hfree&&vfree&&(x<306)&&(x>100)&&(y<257)&&(y>100);
	   free = {{3{free[0]}},free[0]};
	  // done = {{3{done[0]}},done[0]};
		r = detect_out & free;// & done;
		g = detect_out & free;// & done;
		b = detect_out & free; //& done;
	end
	
	// Initiating state machine
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			current_state<=step1;
		end
		else begin
			current_state<=next_state;	
		end
	end
	
	always @*
		case (current_state)
		step1: if (convp_done) next_state=step2;
			   else next_state=step1;
		step2: if (convs_done) next_state=step3;
			   else next_state=step2;
		step3: if(convfinal_done) next_state=step4; 
			   else	next_state=step3;
	    step4: if (pat_detect_done) next_state=step5;
			   else next_state=step4; 
		step5: if (rst) next_state=step1;
			   else next_state=step5;
				 
		endcase
	
		always @* begin		
				pattern_en = 1'b0; convpmem_en = 1'b0; convpmem_wr = 1'b0; sample_en = 1'b0; convsmem_en = 1'b0; 
				convsmem_wr = 1'b0; convp_en = 1'b0; convs_en = 1'b0; finalconv_en = 1'b0; detectcount_en = 1'b0;
				convfinalmem_wr = 1'b0; maxpool_en = 1'b0; pat_detect_en = 1'b0; detect_mem_wr = 1'b0;
		case (current_state)
		step1: begin
				 pattern_en = 1'b1; convpmem_en = 1'b1; convpmem_wr = 1'b1; 
				 end
		step2: begin
				 sample_en = 1'b1; convsmem_en = 1'b1; convsmem_wr = 1'b1;
				 end
		step3: begin
				 convp_en = 1'b1; convs_en = 1'b1; finalconv_en = 1'b1; 
				 convfinalmem_wr = 1'b1;  maxpool_en = 1'b1; 
			    end
		step4: begin	
				 pat_detect_en = 1'b1; detect_mem_wr = 1'b1;
				 end
		step5: begin	
				 detectcount_en = 1'b1;
				 end

		endcase

		end
endmodule





