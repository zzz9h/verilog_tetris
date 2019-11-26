`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:01:58 06/03/2019
// Design Name:   game_clock
// Module Name:   E:/xiangmu_5/game_clock_text.v
// Project Name:  xiangmu_5
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: game_clock
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module game_clock_text;

	// Inputs
	reg clk;
	reg rst;
	reg pause;

	// Outputs
	wire game_clk;

	// Instantiate the Unit Under Test (UUT)
	game_clock uut (
		.clk(clk), 
		.rst(rst), 
		.pause(pause), 
		.game_clk(game_clk)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		pause =0;

		// Wait 100 ns for global reset to finish
		#100;
		pause =1;
		#100;
		rst = 1;
		pause = 0;
		#100;
		rst = 1;
		pause = 0;
      #5;
      rst=0;
 end
  parameter CYCLE = 10;
  initial begin
  clk=0;
  forever
  #(CYCLE/2)
  clk=~clk;
		// Add stimulus here

	end
      
endmodule

