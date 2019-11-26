`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:34:45 06/01/2019
// Design Name:   randomizer
// Module Name:   E:/xiangmu_2_suijishu/randomizer_text.v
// Project Name:  xiangmu_2_suijishu
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: randomizer
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module randomizer_text;

	// Inputs
	reg clk;

	// Outputs
	wire [2:0] random;

	// Instantiate the Unit Under Test (UUT)
	randomizer uut (
		.clk(clk), 
		.random(random)
	);
	parameter CYCLE    = 10;
   parameter RST_TIME = 5 ; //生成本地时钟100M
	initial begin
                clk = 0;
                forever
                #(CYCLE/2)
                clk=~clk;//时钟翻转
            end
      
endmodule

