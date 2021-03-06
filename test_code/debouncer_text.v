`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:04:43 06/01/2019
// Design Name:   debouncer
// Module Name:   E:/xiangmu_3_debouncer/debouncer_text.v
// Project Name:  xiangmu_3_debouncer
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: debouncer
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module debouncer_text;

	// Inputs
	reg raw;
	reg clk;

	// Outputs
	wire enabled;
	wire disabled;

	// Instantiate the Unit Under Test (UUT)
	debouncer uut (
		.raw(raw), 
		.clk(clk), 
		.enabled(enabled), 
		.disabled(disabled)
	);

   parameter CYCLE    = 10;
  // parameter RST_TIME = 5 ; //生成本地时钟100M
	initial begin
	             raw = 1;//高电平有效
                clk = 0;
                forever
                #(CYCLE/2)
                clk=~clk;//时钟翻转
            end
      
endmodule

