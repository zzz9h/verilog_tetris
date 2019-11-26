// 屏幕宽度
`define PIXEL_WIDTH 1024
// 屏幕长度
`define PIXEL_HEIGHT 768

// 用于VGA水平和垂直同步
`define HSYNC_FRONT_PORCH 24
`define HSYNC_PULSE_WIDTH 136
`define HSYNC_BACK_PORCH 160
`define VSYNC_FRONT_PORCH 3
`define VSYNC_PULSE_WIDTH 6
`define VSYNC_BACK_PORCH 29

// 每个块有多少像素宽/高
`define BLOCK_SIZE 30

// 游戏区域有一行有多少块
`define BLOCKS_WIDE 10

// 游戏区域有最高位多少块
`define BLOCKS_HIGH 22

// 游戏板的宽度（像素）
`define BOARD_WIDTH (`BLOCKS_WIDE * `BLOCK_SIZE)
// 方块初始位置(x)
`define BOARD_X (((`PIXEL_WIDTH - `BOARD_WIDTH) / 2) - 1)

// 游戏板的高度(像素）
`define BOARD_HEIGHT (`BLOCKS_HIGH * `BLOCK_SIZE)
// 方块的初始位置(y)
`define BOARD_Y (((`PIXEL_HEIGHT - `BOARD_HEIGHT) / 2) - 1)

// 用于存储块位置的位数。
`define BITS_BLK_POS 8
// 用于存储X位置的位数。
`define BITS_X_POS 4
// 用于存储Y位置的位数
`define BITS_Y_POS 5
// 用于存储旋转的位数
`define BITS_ROT 2
// 用于存储块的宽度/长度的位数（最大值为十进制4）
`define BITS_BLK_SIZE 3
// 分数的位数。 得分上升到9999
`define BITS_SCORE 14
// 用于存储静止方块的位置
`define BITS_PER_BLOCK 3

// 每个块的类型
`define EMPTY_BLOCK 3'b000
`define I_BLOCK 3'b001
`define O_BLOCK 3'b010
`define T_BLOCK 3'b011
`define S_BLOCK 3'b100
`define Z_BLOCK 3'b101
`define J_BLOCK 3'b110
`define L_BLOCK 3'b111

// 随机颜色的值
`define WHITE 8'b11111111
`define BLACK 8'b00000000
`define GRAY 8'b10100100
`define CYAN 8'b11110000
`define YELLOW 8'b00111111
`define PURPLE 8'b11000111
`define GREEN 8'b00111000
`define RED 8'b00000111
`define BLUE 8'b11000000
`define ORANGE 8'b00011111

// 错误代码
`define ERR_BLK_POS 8'b11111111

// 状态机模式选择
`define MODE_BITS 3
`define MODE_PLAY 0
`define MODE_DROP 1
`define MODE_PAUSE 2
`define MODE_IDLE 3
`define MODE_SHIFT 4

// 下降计时器的最大值
`define DROP_TIMER_MAX 10000
