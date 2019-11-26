

module vga_display(
    input                  en,
    input  [1439:0]       data   ,
    input  [507:0]       data_1   ,
    input   [7:0]	      data_T   ,
    input wire                                   clk,
    input wire [ BITS_PER_BLOCK-1:0]             cur_piece,
    input wire [ BITS_BLK_POS-1:0]               cur_blk_1,
    input wire [ BITS_BLK_POS-1:0]               cur_blk_2,
    input wire [ BITS_BLK_POS-1:0]               cur_blk_3,
    input wire [ BITS_BLK_POS-1:0]               cur_blk_4,
    input wire [( BLOCKS_WIDE* BLOCKS_HIGH)-1:0] fallen_pieces,
    output reg [7:0]                             rgb,
    output reg                                  hsync,
    output reg                                  vsync,
	 output [5:0]    rom_adder_16 ,
    output [15:0]	          adder,
    output                 rom_en,
	 output [5:0]    rom_adder_17 ,
    output [15:0]	          adder_1,
    output                 rom_en_1
    );
	 
    reg    					spriteon  ;
	 reg    				  spriteon_T ;
	 reg                    rom_en;
	 reg                    rom_en_1   				;//t
    reg                    spriteon_1 				;//待显示区域有效//t
	 wire       [10:0]      rom_adder_1				;
    wire       [10:0]      rom_pix_1  				;
	 wire       [507:0]     data_1                ;//字符rom
	 wire       [5:0]       adder_1               ;
reg vidon;
					
	 wire   [10:0]			rom_adder;
	 wire   [10:0]			rom_pix	;
	 wire   [10:0]        y_pix   ;
    wire   [10:0]        x_pix   ;
	 wire   [16:0]      rom_adder1;
    wire   [16:0]      rom_adder2;
	 wire [2:0] red;
	 wire [2:0]  green;
	 wire  [1:0]blue;
	 wire  [15:0]adder;
parameter 					PIXEL_WIDTH = 1024;
parameter 					PIXEL_HEIGHT = 768;
parameter 					HSYNC_FRONT_PORCH = 24;
parameter 					HSYNC_PULSE_WIDTH = 136;
parameter 					HSYNC_BACK_PORCH = 160;
parameter 					VSYNC_FRONT_PORCH = 3;
parameter 					VSYNC_PULSE_WIDTH = 6;
parameter 					VSYNC_BACK_PORCH = 29;
parameter  H_BP  =11'd296 ;        //行显示后沿（96+48）
parameter  V_BP  =11'd35  ;        //场显示后沿 (2+33 ）
parameter  DATA_W=11'd800 ;     //显示数据的宽度 （32列）
parameter  DATA_H=40'd40  ;        //显示数据的高度 （16行）


parameter  W=11'd70      ;        // X方向偏移的位置
parameter  H=10'd98       ;       // Y方向偏移的位置



parameter  W_1		= 10'd247							;// X方向偏移的位置
parameter  H_1		= 10'd364							;// Y方向偏移的位置
parameter  DATA_W_1= 10'd500							;//显示数据的宽度 
parameter  DATA_H_1= 10'd40								;//显示数据的高度 

assign  rom_adder      =  counter_y-V_BP-H;
assign  rom_pix        =  counter_x-H_BP-W;
assign  rom_adder_16   =  rom_adder[5:0];

assign  rom_adder_1		=  counter_y-V_BP-H_1			;
assign  rom_pix_1			=  counter_x-H_BP-W_1			;
assign  rom_adder_17	  	=  rom_adder_1[5:0]	; //rom的实际地址

// 每个块有多少像素宽/高
parameter BLOCK_SIZE =30;

// 游戏区域有一行有多少块
parameter BLOCKS_WIDE =10;

// 游戏区域有最高位多少块
parameter BLOCKS_HIGH =22;
// 游戏板的宽度（像素）
parameter BOARD_WIDTH =( BLOCKS_WIDE *  BLOCK_SIZE);
// 方块初始位置(x)
parameter BOARD_X =((( PIXEL_WIDTH -  BOARD_WIDTH) / 2)+310 );

// 游戏板的高度(像素）
parameter BOARD_HEIGHT =( BLOCKS_HIGH *  BLOCK_SIZE);
// 方块的初始位置(y)
parameter BOARD_Y =((( PIXEL_HEIGHT -  BOARD_HEIGHT) / 2)-1);

// 用于存储块位置的位数。
parameter BITS_BLK_POS =8;
// 用于存储X位置的位数。
parameter BITS_X_POS =4;
// 用于存储Y位置的位数
parameter BITS_Y_POS= 5;
// 用于存储旋转的位数
parameter BITS_ROT= 2;
// 用于存储块的宽度/长度的位数（最大值为十进制4）
parameter BITS_BLK_SIZE =3;
// 分数的位数。 得分上升到9999
parameter BITS_SCORE =14;
// 用于存储静止方块的位置
parameter BITS_PER_BLOCK =3;
parameter H_BACK = HSYNC_PULSE_WIDTH + HSYNC_BACK_PORCH;
parameter V_BACK = VSYNC_PULSE_WIDTH + VSYNC_BACK_PORCH;
parameter H_TOTAL = H_BACK + PIXEL_WIDTH + HSYNC_FRONT_PORCH;
parameter V_TOTAL = V_BACK + PIXEL_HEIGHT + VSYNC_FRONT_PORCH;
parameter EMPTY_BLOCK =3'b000;
parameter I_BLOCK =3'b001;
parameter O_BLOCK =3'b010;
parameter T_BLOCK =3'b011;
parameter S_BLOCK =3'b100;
parameter Z_BLOCK =3'b101;
parameter J_BLOCK =3'b110;
parameter L_BLOCK =3'b111;

// 随机颜色的值
parameter WHITE =8'b11111111;
parameter BLACK =8'b00000000;
parameter GRAY =8'b10100100;
parameter CYAN =8'b11110000;
parameter YELLOW =8'b00111111;
parameter PURPLE= 8'b11000111;
parameter GREEN =8'b00111000;
parameter RED =8'b00000111;
parameter BLUE =8'b11000000;
parameter ORANGE =8'b00011111;
  parameter H_SYNC   = 10'd136;      //行同步 
  parameter H_DISP   = 11'd1024;     //行有效数据 
  parameter H_FRONT  = 10'd24;      //行显示前沿 
  parameter V_SYNC   = 10'd6;       //场同步 
  parameter V_DISP   = 10'd768;     //场有效数据 
  parameter V_FRONT  = 10'd3;      //场显示前沿 

assign  rom_adder      =  counter_y-V_BP-H;
assign  rom_pix        =  counter_x-H_BP-W;
assign  rom_adder_16   =  rom_adder[5:0];

assign  rom_adder_1		=  counter_y-V_BP-H_1			;
assign  rom_pix_1			=  counter_x-H_BP-W_1			;
assign  rom_adder_17	  	=  rom_adder_1[5:0]	;

    reg [10:0] counter_x = 0;
    reg [10:0] counter_y = 0;
 
   

    // Combinational logic to select the current pixel
    wire [10:0] cur_blk_index = ((counter_x- BOARD_X)/ BLOCK_SIZE) + (((counter_y- BOARD_Y)/ BLOCK_SIZE)* BLOCKS_WIDE);
    reg [2:0] cur_vid_mem;
	 
	 always@(*)begin

      if  (((counter_x >= 298) && (counter_x < 1332)) 
         &&((counter_y>= 35) && (counter_y < 803))) begin 
            
             vidon=1'b1;
        end

        else begin
        
            vidon=1'b0;
        end

    end
	 
	 always  @(*)begin

        if  (((counter_x >= H_BP+W) && (counter_x < H_BP+W+DATA_W)) 
         &&((counter_y >= V_BP+H) && (counter_y < V_BP+H+DATA_H))) begin 
            
             spriteon=1'b1;
        end
        else begin
        
            spriteon=1'b0;
        end
end

	always@(*)begin
		if  (((counter_x >= H_BP+W_1) && (counter_x < H_BP+W_1+DATA_W_1)) 
			&&((counter_y >= V_BP+H_1) && (counter_y < V_BP+H_1+DATA_H_1))) begin 
			
				spriteon_1 = 1'b1;
		end
		else begin
				spriteon_1 = 1'b0;
		end
	end

	
    always @ (clk) begin
	 if(!en)begin
if((vidon==1'b1)&&(spriteon==1'b1))begin
        
        if (data[790-rom_pix]==1'b1) begin      //字符显示红色

           rgb=PURPLE;

        end
        else begin                      //非字符显示白色

          rgb=BLACK;

   
        end  
        end
		  else if((vidon==1'b1)&&(spriteon_1==1'b1))begin
				if(data_1[510-rom_pix_1]==1'b1) begin   		//字符显示白色
					rgb=PURPLE;
				end
				else begin										 	 	//非字符显示黑色
				  rgb=BLACK;
				end
        
        end
    else begin                           //显示黑色

       rgb=BLACK;
   
    end  
end
else begin
        if (counter_x >= BOARD_X && counter_y >= BOARD_Y &&
			counter_x <= BOARD_X + BOARD_WIDTH && counter_y <= BOARD_Y + BOARD_HEIGHT) begin
		if (counter_x == BOARD_X || counter_x == BOARD_X + BOARD_WIDTH ||
				counter_y == BOARD_Y || counter_y == BOARD_Y + BOARD_HEIGHT) begin
                // 游戏界面边框
                rgb =  WHITE;
            end else begin
                if (cur_blk_index == cur_blk_1 ||
                    cur_blk_index == cur_blk_2 ||
                    cur_blk_index == cur_blk_3 ||
                    cur_blk_index == cur_blk_4) begin
                    case (cur_piece)
                         EMPTY_BLOCK: rgb =  CYAN;
                         I_BLOCK: rgb = GRAY;
                         O_BLOCK: rgb = YELLOW;
                         T_BLOCK: rgb =  PURPLE;
                         S_BLOCK: rgb =  GREEN;
                         Z_BLOCK: rgb =  RED;
                         J_BLOCK: rgb = BLUE;
                         L_BLOCK: rgb =  ORANGE;
                    endcase
                end else begin
                    rgb = fallen_pieces[cur_blk_index] ?  WHITE :  CYAN;
                end
            end
        end 
		  else begin
            // 游戏界面外
            rgb =  BLACK;
        end
		  end
    end

always@(posedge clk)begin
   if (counter_x==H_TOTAL-1) begin
      counter_x<=11'b0;
      end
   else begin
      counter_x<=counter_x+1'b1;
      end
   end

//场扫描计数器
always@(posedge clk)begin		
   if(counter_x==H_TOTAL-1) begin			//一列一列扫
      if(counter_y==V_TOTAL-1) begin
			counter_y<=10'b0;
         end           
      else begin
         counter_y<=counter_y+1'b1;
         end
      end
	else begin
      counter_y<=counter_y;
      end
   end
	assign rom_adder1={y_pix,7'b0000000}+{1'b0,y_pix,6'b000000}
                  +{2'b00,y_pix,5'b00000}+{3'b000,y_pix,4'b0000};

assign rom_adder2=rom_adder1+{8'b0000_0000,x_pix};

assign  adder   =  rom_adder2[15:0]; //rom的实际地址   
assign  y_pix =  counter_y-V_BP-H;  //0-159
assign  x_pix =  counter_x-H_BP-W;  //0-239
wire hsync1;
wire vsync1;
assign hsync1 = (counter_x <= 136 - 1'b1) ? 1'b0 : 1'b1; 

assign vsync1 = (counter_y <= 6 - 1'b1) ? 1'b0 : 1'b1; 

always@(posedge clk)begin	
hsync<=hsync1;
vsync<=vsync1;
end	
endmodule
