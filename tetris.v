`include "definitions.vh"
module tetris(
input wire en,
    input wire        clk_too_fast,
    input wire        btn_drop,
    input wire        btn_rotate,
    input wire        btn_left,
    input wire        btn_right,
    input wire        btn_down,
    input wire        sw_pause,
    input wire        sw_rst,
    output wire [7:0] rgb,
    output wire       hsync,
    output wire       vsync,
    output wire [7:0] seg,
    output wire [3:0] an,
	 input wire   clk_rst
    );




    //获得65M的时钟
	 	wire  [5:0] rom_addr;
	wire  [1439:0] data;
	wire [15:0] rom_addr_T;
	wire [15:0] rom_addr_T1;
	wire  [5:0] rom_addr_1;
	wire  [507:0] data_1;


	 wire clk;
	 wire clk_65;
	 wire LOCKED;
	 
	 
	 rom_data    u4   ( .adder (rom_addr)     ,
                   .data (data)
                 );
					  
rom_data1  u5   ( .adder_1 (rom_addr_1) ,
                   .data_1 (data_1)
                 );
 clk_65M instance_name
   (// Clock in ports
    .CLK(clk_too_fast),      // IN
    .CLK_45M(clk),
	 .CLK_65M(clk_65),     // OUT
    // Status and control signals
    .RESET(clk_rst),// IN
    .LOCKED(LOCKED)); 
	    // 每循环增加一次，达到最大值。如果还没有达到最大值，就不能进入下降模式。
    reg [31:0] drop_timer;
    initial begin
        drop_timer = 0;
    end
	 


    // T该信号随机件在100兆赫频率下在不同类型的块之间旋转，
	 //并根据用户输入进行选择，使其有效地随机。
    wire [`BITS_PER_BLOCK-1:0] random_piece;
    randomizer randomizer_ (
        .clk(clk),
        .random(random_piece)
    );

    // 五个按钮通过去缓冲后的启用信号。每按一次按钮，一个周期内只能按一个。
    wire btn_drop_en;
    wire btn_rotate_en;
    wire btn_left_en;
    wire btn_right_en;
    wire btn_down_en;
    // 消除所有输入信号的干扰
    debouncer debouncer_btn_drop_ (
        .raw(btn_drop),
        .clk(clk),
        .enabled(btn_drop_en)
    );
    debouncer debouncer_btn_rotate_ (
        .raw(btn_rotate),
        .clk(clk),
        .enabled(btn_rotate_en)
    );
    debouncer debouncer_btn_left_ (
        .raw(btn_left),
        .clk(clk),
        .enabled(btn_left_en)
    );
    debouncer debouncer_btn_right_ (
        .raw(btn_right),
        .clk(clk),
        .enabled(btn_right_en)
    );
    debouncer debouncer_btn_down_ (
        .raw(btn_down),
        .clk(clk),
        .enabled(btn_down_en)
    );

    // Sets up wires for the pause and reset switch enable
    // and disable signals, and debounces the asynchronous input.
    wire sw_pause_en;
    wire sw_pause_dis;
    wire sw_rst_en;
    wire sw_rst_dis;
    debouncer debouncer_sw_pause_ (
        .raw(sw_pause),
        .clk(clk),
        .enabled(sw_pause_en),
        .disabled(sw_pause_dis)
    );
    debouncer debouncer_sw_rst_ (
        .raw(sw_rst),
        .clk(clk),
        .enabled(sw_rst_en),
        .disabled(sw_rst_dis)
    );

    // 一种存储器组，用于为每个板位置存储1位。如果下落的方块为1，则仍有一个块未从游戏中移除。这是用来绘制和测试与下落的方块于静止的交叉。
    reg [(`BLOCKS_WIDE*`BLOCKS_HIGH)-1:0] fallen_pieces;

    // 当前坠落的方块是什么类型的方块
    reg [`BITS_PER_BLOCK-1:0] cur_piece;
    //下落块x位置。
    reg [`BITS_X_POS-1:0] cur_pos_x;
    //下落块y位置。.
    reg [`BITS_Y_POS-1:0] cur_pos_y;
    // 下落块的当前旋转（0=0度、1=90度等）
    reg [`BITS_ROT-1:0] cur_rot;
    // 当前下降的小方块的四个位置。用于测试交叉点，或添加到落下的方块等
    wire [`BITS_BLK_POS-1:0] cur_blk_1;
    wire [`BITS_BLK_POS-1:0] cur_blk_2;
    wire [`BITS_BLK_POS-1:0] cur_blk_3;
    wire [`BITS_BLK_POS-1:0] cur_blk_4;
    // 根据方块的类型和旋转，确定其当前形状的宽度和高度。
    wire [`BITS_BLK_SIZE-1:0] cur_width;
    wire [`BITS_BLK_SIZE-1:0] cur_height;
    //使用Calc Cur_BLK模块从下落的方块当前位置、类型和旋转中获取上述的值。
    calc_cur_blk calc_cur_blk_ (
        .piece(cur_piece),
        .pos_x(cur_pos_x),
        .pos_y(cur_pos_y),
        .rot(cur_rot),
        .blk_1(cur_blk_1),
        .blk_2(cur_blk_2),
        .blk_3(cur_blk_3),
        .blk_4(cur_blk_4),
        .width(cur_width),
        .height(cur_height)
    );

    // VGA显示。我们给它一个方块（cur-piece）的类型，以便它知道正确的颜色，
	 //以及它所覆盖的板上的四个位置。我们也会通过掉下来的方块，
	// 这样它就可以以单色显示掉下来的方块。
    vga_display display_ (
	      .en(en),
        .clk(clk_65),
        .cur_piece(cur_piece),
        .cur_blk_1(cur_blk_1),
        .cur_blk_2(cur_blk_2),
        .cur_blk_3(cur_blk_3),
        .cur_blk_4(cur_blk_4),
        .fallen_pieces(fallen_pieces),
        .rgb(rgb),
        .hsync(hsync),
        .vsync(vsync),
		  .rom_adder_16(rom_addr),
		  .data(data),
			.rom_en(rom_en),
			.adder(rom_addr_T),
			.data_T(data_T),
			.data_1(data_1),
		   .rom_adder_17(rom_addr_1),
			.adder_1(rom_addr_T1),
			.rom_en_1(rom_en_1)
    );

    // 用于有限状态机的事件。我们还需要偶尔存储旧模式，比如暂停时。
    reg [`MODE_BITS-1:0] mode;
    reg [`MODE_BITS-1:0] old_mode;
    // 游戏时钟
    wire game_clk;
    //游戏时钟复位
    reg game_clk_rst;

    // 这个模块输出游戏时钟，这是当时钟决定何时方块下降。
    game_clock game_clock_ (
        .clk(clk),
        .rst(game_clk_rst),
        .pause(mode != `MODE_PLAY),
        .game_clk(game_clk)
    );

    //设置一些变量来测试当前工件的交集或屏幕外状态（如果用户的当前操作要被执行）。
	 //例如，如果用户按左键，我们将测试当前块向左移动的位置，即x=x-1。
    wire [`BITS_X_POS-1:0] test_pos_x;
    wire [`BITS_Y_POS-1:0] test_pos_y;
    wire [`BITS_ROT-1:0] test_rot;
    // 确定我们测试的位置/旋转的组合逻辑。它被写到一个模块中，这样代码就更短了。
    calc_test_pos_rot calc_test_pos_rot_ (
        .mode(mode),
        .game_clk_rst(game_clk_rst),
        .game_clk(game_clk),
        .btn_left_en(btn_left_en),
        .btn_right_en(btn_right_en),
        .btn_rotate_en(btn_rotate_en),
        .btn_down_en(btn_down_en),
        .btn_drop_en(btn_drop_en),
        .cur_pos_x(cur_pos_x),
        .cur_pos_y(cur_pos_y),
        .cur_rot(cur_rot),
        .test_pos_x(test_pos_x),
        .test_pos_y(test_pos_y),
        .test_rot(test_rot)
    );
    // 设置计算测试模块的输出
    wire [`BITS_BLK_POS-1:0] test_blk_1;
    wire [`BITS_BLK_POS-1:0] test_blk_2;
    wire [`BITS_BLK_POS-1:0] test_blk_3;
    wire [`BITS_BLK_POS-1:0] test_blk_4;
    wire [`BITS_BLK_SIZE-1:0] test_width;
    wire [`BITS_BLK_SIZE-1:0] test_height;
    calc_cur_blk calc_test_block_ (
        .piece(cur_piece),
        .pos_x(test_pos_x),
        .pos_y(test_pos_y),
        .rot(test_rot),
        .blk_1(test_blk_1),
        .blk_2(test_blk_2),
        .blk_3(test_blk_3),
        .blk_4(test_blk_4),
        .width(test_width),
        .height(test_height)
    );

    // 此函数检查其输入块位置是否与任何落下的块相交。
    function intersects_fallen_pieces;
        input wire [7:0] blk1;
        input wire [7:0] blk2;
        input wire [7:0] blk3;
        input wire [7:0] blk4;
        begin
            intersects_fallen_pieces = fallen_pieces[blk1] ||
                                       fallen_pieces[blk2] ||
                                       fallen_pieces[blk3] ||
                                       fallen_pieces[blk4];
        end
    endfunction

    // 当遇到位置/旋转与下落块相交时，此信号变高。
    wire test_intersects = intersects_fallen_pieces(test_blk_1, test_blk_2, test_blk_3, test_blk_4);

    // 判断可以向左移动，则向左移动。
    task move_left;
        begin
            if (cur_pos_x > 0 && !test_intersects) begin
                cur_pos_x <= cur_pos_x - 1;
            end
        end
    endtask

    // 判断可以向右移动，则向右移动。
    task move_right;
        begin
            if (cur_pos_x + cur_width < `BLOCKS_WIDE && !test_intersects) begin
                cur_pos_x <= cur_pos_x + 1;
            end
        end
    endtask

    // 如果当前块不会导致块的任何部分离开屏幕并且不会与任何掉落的块相交，则旋转当前块。
    task rotate;
        begin
            if (cur_pos_x + test_width <= `BLOCKS_WIDE &&
                cur_pos_y + test_height <= `BLOCKS_HIGH &&
                !test_intersects) begin
                cur_rot <= cur_rot + 1;
            end
        end
    endtask

    // 将当前块添加到下落的方块
    task add_to_fallen_pieces;
        begin
            fallen_pieces[cur_blk_1] <= 1;
            fallen_pieces[cur_blk_2] <= 1;
            fallen_pieces[cur_blk_3] <= 1;
            fallen_pieces[cur_blk_4] <= 1;
        end
    endtask

    // 将给定的块添加到下落的块中，并为出现在屏幕顶部的用户选择一个新块。
    task get_new_block;
        begin
            // 重置下降计时器，直到足够高才能下降
            drop_timer <= 0;
            // Choose a new block for the user
            cur_piece <= random_piece;
            cur_pos_x <= (`BLOCKS_WIDE / 2) - 1;
            cur_pos_y <= 0;
            cur_rot <= 0;
            // 重置游戏计时器，使用户在程序块下降前有一个完整的周期。
            game_clk_rst <= 1;
        end
    endtask

    // 将当前块向下移动一个，如果该块离开板或与另一个块相交，则获取一个新块。
    task move_down;
        begin
            if (cur_pos_y + cur_height < `BLOCKS_HIGH && !test_intersects) begin
                cur_pos_y <= cur_pos_y + 1;
            end else begin
                add_to_fallen_pieces();
                get_new_block();
            end
        end
    endtask

    // 将模式设置为模式_drop，在该模式中，当前块不会响应用户输入，它将以每秒一个周期的速度向下移动，直到碰到块或板的底部。
    task drop_to_bottom;
        begin
            mode <= `MODE_DROP;
        end
    endtask

    // 分数寄存器，当用户完成一行时增加一个。
    reg [3:0] score_1; // 1's place
    reg [3:0] score_2; // 10's place
    reg [3:0] score_3; // 100's place
    reg [3:0] score_4; // 1000's place
    // 7段显示模块，输出分数
    seg_display score_display_ (
        .clk(clk),
        .score_1(score_1),
        .score_2(score_2),
        .score_3(score_3),
        .score_4(score_4),
        .an(an),
        .seg(seg)
    );
    // 确定哪一行（如果有的话）是完整的，需要删除的模块，分数递增。
    wire [`BITS_Y_POS-1:0] remove_row_y;
    wire remove_row_en;
    complete_row complete_row_ (
        .clk(clk),
        .pause(mode != `MODE_PLAY),
        .fallen_pieces(fallen_pieces),
        .row(remove_row_y),
        .enabled(remove_row_en)
    );

    // 此任务从掉落的碎片中删除已完成的行
    // 并增加分数
    reg [`BITS_Y_POS-1:0] shifting_row;
    task remove_row;
        begin
            // 移走，消除行
            mode <= `MODE_SHIFT;
            shifting_row <= remove_row_y;
            // 增加分数
            if (score_1 == 9) begin
                if (score_2 == 9) begin
                    if (score_3 == 9) begin
                        if (score_4 != 9) begin
                            score_4 <= score_4 + 1;
                            score_3 <= 0;
                            score_2 <= 0;
                            score_1 <= 0;
                        end
                    end else begin
                        score_3 <= score_3 + 1;
                        score_2 <= 0;
                        score_1 <= 0;
                    end
                end else begin
                    score_2 <= score_2 + 1;
                    score_1 <= 0;
                end
            end else begin
                score_1 <= score_1 + 1;
            end
        end
    endtask

    //初始化我们需要的任何寄存器
    initial begin
        mode = `MODE_IDLE;
        fallen_pieces = 0;
        cur_piece = `EMPTY_BLOCK;
        cur_pos_x = 0;
        cur_pos_y = 0;
        cur_rot = 0;
        score_1 = 0;
        score_2 = 0;
        score_3 = 0;
        score_4 = 0;
    end

    // 在模式“空闲”状态下按下按钮后开始新游戏
    task start_game;
        begin
            mode <= `MODE_PLAY;
            fallen_pieces <= 0;
            score_1 <= 0;
            score_2 <= 0;
            score_3 <= 0;
            score_4 <= 0;
            get_new_block();
        end
    endtask

    // 确定游戏是否因当前位置而结束
    // 与坠落的方块相交
    wire game_over = cur_pos_y == 0 && intersects_fallen_pieces(cur_blk_1, cur_blk_2, cur_blk_3, cur_blk_4);

    //游戏主逻辑
    always @ (posedge clk) begin
        if (drop_timer < `DROP_TIMER_MAX) begin
            drop_timer <= drop_timer + 1;
        end
        game_clk_rst <= 0;
        if (mode == `MODE_IDLE && (sw_rst_en || sw_rst_dis)) begin
            // 我们处于空闲模式，用户已请求启动游戏
            start_game();
        end else if (sw_rst_en || sw_rst_dis || game_over) begin
            // 按了重置开关或者游戏本身就结束了
				// 进入空闲模式，等待用户按下按钮
            mode <= `MODE_IDLE;
            add_to_fallen_pieces();
            cur_piece <= `EMPTY_BLOCK;
        end else if ((sw_pause_en || sw_pause_dis) && mode == `MODE_PLAY) begin
            // 如果我们打开暂停，保存旧模式并进入
            // 暂停模式
            mode <= `MODE_PAUSE;
            old_mode <= mode;
        end else if ((sw_pause_en || sw_pause_dis) && mode == `MODE_PAUSE) begin
            // 如果我们关闭暂停，进入旧模式
            mode <= old_mode;
        end else if (mode == `MODE_PLAY) begin
            // 正常游戏
            if (game_clk) begin
                move_down();
            end else if (btn_left_en) begin
                move_left();
            end else if (btn_right_en) begin
                move_right();
            end else if (btn_rotate_en) begin
                rotate();
            end else if (btn_down_en) begin
                move_down();
            end else if (btn_drop_en && drop_timer == `DROP_TIMER_MAX) begin
                drop_to_bottom();
            end else if (remove_row_en) begin
                remove_row();
            end
        end else if (mode == `MODE_DROP) begin
            // 我们要把方块放下，直到我们重新开始
            // 在顶部
            if (game_clk_rst && !sw_pause_en) begin
                mode <= `MODE_PLAY;
            end else begin
                move_down();
            end
        end else if (mode == `MODE_SHIFT) begin
            // 我们要把上面的那一排换成另一排
            // 转换成行的位置
            if (shifting_row == 0) begin
                fallen_pieces[0 +: `BLOCKS_WIDE] <= 0;
                mode <= `MODE_PLAY;
            end else begin
                fallen_pieces[shifting_row*`BLOCKS_WIDE +: `BLOCKS_WIDE] <= fallen_pieces[(shifting_row - 1)*`BLOCKS_WIDE +: `BLOCKS_WIDE];
                shifting_row <= shifting_row - 1;
            end
        end
    end

endmodule
