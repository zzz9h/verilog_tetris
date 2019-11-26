`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:59:38 06/09/2019
// Design Name:   vga_display
// Module Name:   C:/Users/zgh29/Desktop/code_f/verilog-tetris-master (2)/tetris/tyu.v
// Project Name:  tetris
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: vga_display
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tyu;

	// Inputs
	reg en;
	reg [1439:0] data;
	reg [507:0] data_1;
	reg [7:0] data_T;
	reg clk;
	reg [2:0] cur_piece;
	reg [7:0] cur_blk_1;
	reg [7:0] cur_blk_2;
	reg [7:0] cur_blk_3;
	reg [7:0] cur_blk_4;
	reg [219:0] fallen_pieces;

	// Outputs
	wire [7:0] rgb;
	wire hsync;
	wire vsync;
	wire [5:0] rom_adder_16;
	wire [15:0] adder;
	wire rom_en;
	wire [5:0] rom_adder_17;
	wire [15:0] adder_1;
	wire rom_en_1;

	// Instantiate the Unit Under Test (UUT)
	vga_display uut (
		.en(en), 
		.data(data), 
		.data_1(data_1), 
		.data_T(data_T), 
		.clk(clk), 
		.cur_piece(cur_piece), 
		.cur_blk_1(cur_blk_1), 
		.cur_blk_2(cur_blk_2), 
		.cur_blk_3(cur_blk_3), 
		.cur_blk_4(cur_blk_4), 
		.fallen_pieces(fallen_pieces), 
		.rgb(rgb), 
		.hsync(hsync), 
		.vsync(vsync), 
		.rom_adder_16(rom_adder_16), 
		.adder(adder), 
		.rom_en(rom_en), 
		.rom_adder_17(rom_adder_17), 
		.adder_1(adder_1), 
		.rom_en_1(rom_en_1)
	);

		initial begin
		// Initialize Inputs
		en=1;
		clk = 0;
		cur_piece = 0;
		cur_blk_1 = 0;
		cur_blk_2 = 0;
		cur_blk_3 = 0;
		cur_blk_4 = 0;
		fallen_pieces=1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
	parameter CYCLE    = 10;
   parameter RST_TIME = 5 ; //生成本地时钟100M
	initial begin
                clk = 0;
                forever
                #(CYCLE/2)
                clk=~clk;
            end
      
endmodule

