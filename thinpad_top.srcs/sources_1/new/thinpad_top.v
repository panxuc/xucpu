`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入（备用，可不用）

    input wire clock_btn,         //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到“ON”时为1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有效
    output wire base_ram_oe_n,       //BaseRAM读使能，低有效
    output wire base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ext_ram_ce_n,       //ExtRAM片选，低有效
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有效
    output wire ext_ram_we_n,       //ExtRAM写使能，低有效

    //直连串口信号
    output wire txd,  //直连串口发送端
    input  wire rxd,  //直连串口接收端

    //Flash存储器信号，参考 JS28F640 芯片手册
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output wire flash_ce_n,         //Flash片选信号，低有效
    output wire flash_oe_n,         //Flash读使能信号，低有效
    output wire flash_we_n,         //Flash写使能信号，低有效
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

    //图像输出信号
    output wire[2:0] video_red,    //红色像素，3位
    output wire[2:0] video_green,  //绿色像素，3位
    output wire[1:0] video_blue,   //蓝色像素，2位
    output wire video_hsync,       //行同步（水平同步）信号
    output wire video_vsync,       //场同步（垂直同步）信号
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐区
);

    assign leds = dip_sw[15:0];

    wire locked, clk_100M, clk_80M, clk_60M;
    reg reset_of_clk100M, reset_of_clk80M, reset_of_clk60M;

    pll_example clk_gen(
        .clk_in1(clk_50M),
        .clk_out1(clk_100M),
        .clk_out2(clk_80M),
        .clk_out3(clk_60M),
        .reset(reset_btn),
        .locked(locked)
    );

    always @(posedge clk_100M or negedge locked) begin
        if (~locked) reset_of_clk100M <= 1'b1;
        else reset_of_clk100M <= 1'b0;
    end

    always @(posedge clk_80M or negedge locked) begin
        if (~locked) reset_of_clk80M <= 1'b1;
        else reset_of_clk80M <= 1'b0;
    end

    always @(posedge clk_60M or negedge locked) begin
        if (~locked) reset_of_clk60M <= 1'b1;
        else reset_of_clk60M <= 1'b0;
    end

    wire [31:0] instrMemAddress;
    wire [31:0] instrMemData;
    wire dataMemReadEnable;
    wire dataMemWriteEnable;
    wire [31:0] dataMemReadData;
    wire [31:0] dataMemWriteData;
    wire [31:0] dataMemAddress;
    wire [3:0] dataMemByteEnable;
    wire dataMemChipSelect;

    CPU u_cpu(
        .clk(clk_50M),
        .rst(reset_btn),
        .instrMemAddress(instrMemAddress),
        .instrMemData(instrMemData),
        .dataMemReadEnable(dataMemReadEnable),
        .dataMemWriteEnable(dataMemWriteEnable),
        .dataMemReadData(dataMemReadData),
        .dataMemWriteData(dataMemWriteData),
        .dataMemAddress(dataMemAddress),
        .dataMemByteEnable(dataMemByteEnable),
        .dataMemChipSelect(dataMemChipSelect)
    );

    RAM u_ram(
        .clk(clk_50M),
        .rst(reset_btn),
        .txd(txd),
        .rxd(rxd),
        .instrMemAddress(instrMemAddress),
        .instrMemData(instrMemData),
        .dataMemReadEnable(dataMemReadEnable),
        .dataMemWriteEnable(dataMemWriteEnable),
        .dataMemReadData(dataMemReadData),
        .dataMemWriteData(dataMemWriteData),
        .dataMemAddress(dataMemAddress),
        .dataMemByteEnable(dataMemByteEnable),
        .dataMemChipSelect(dataMemChipSelect),
        .base_ram_data(base_ram_data),
        .base_ram_addr(base_ram_addr),
        .base_ram_be_n(base_ram_be_n),
        .base_ram_ce_n(base_ram_ce_n),
        .base_ram_oe_n(base_ram_oe_n),
        .base_ram_we_n(base_ram_we_n),
        .ext_ram_data(ext_ram_data),
        .ext_ram_addr(ext_ram_addr),
        .ext_ram_be_n(ext_ram_be_n),
        .ext_ram_ce_n(ext_ram_ce_n),
        .ext_ram_oe_n(ext_ram_oe_n),
        .ext_ram_we_n(ext_ram_we_n)
    );

endmodule
