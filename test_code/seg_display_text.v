`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:17:27 06/01/2019
// Design Name:   seg_display
// Module Name:   E:/xiangmu_4_display/seg_display_text.v
// Project Name:  xiangmu_4_display
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: seg_display
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module seg_display_text;

	// Inputs
	reg clk;
	reg [3:0] score_1;
	reg [3:0] score_2;
	reg [3:0] score_3;
	reg [3:0] score_4;

	// Outputs
	reg [7:0] seg;
	reg [3:0] an;

	// Instantiate the Unit Under Test (UUT)
	seg_display uut (
		.clk(clk), 
		.score_1(score_1), 
		.score_2(score_2), 
		.score_3(score_3), 
		.score_4(score_4), 
		.seg(seg), 
		.an(an)
	);

	initial begin
		// Initialize Inputs

		score_1 = 1;
		score_2 = 2;
		score_3 = 3;
		score_4 = 4;
      
		// Add stimulus here

	end
   parameter CYCLE    = 10;
 
	
	 //生成本地时钟100M
	initial begin
                clk = 0;
                forever
                #(CYCLE/2)
                clk=~clk;
            end
endmodule

