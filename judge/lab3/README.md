#### 测试说明

本实验需要实现一个 32 位 LoongArch CPU，支持LoongArch-C3指令集的 21 条指令：addi.w add.w sub.w lu12i.w pcaddu12i or ori andi and xor srli.w slli.w jirl b beq bne bl st.w ld.w st.b ld.b。测试器将利用监控程序（基础版）对CPU功能进行验证。

测试过程对CPU实现有如下要求：

1. 虚拟内存空间为0x80000000～0x807FFFFF，共8MB。其中
   - 0x80000000～0x803FFFFF映射到BaseRAM；
   - 0x80400000～0x807FFFFF映射到ExtRAM。
2. CPU字节序为小端序。
3. 支持串口信号txd/rxd，波特率9600，数据8位，停止1位，无校验位，串口控制器的地址映射按照监控程序要求。
4. CPU时钟使用外部时钟输入，50MHz / 11MHz两路时钟输入均可使用。
5. 在复位按钮按下时（高电平）CPU处于复位状态，松开后解除。
6. CPU复位后从0x80000000开始取指令执行。

#### 测试步骤

1. 将拨码开关设置为0
2. Kernel下载到BaseRAM中
3. 单击复位按钮
4. 模拟Term程序连接串口，等待Kernel启动时的欢迎信息
5. 用A命令将用户程序加载到0x80100000处
6. 用D命令读出用户程序，检查是否正确加载
7. 用G命令执行用户程序
8. 用R和D命令读取用户程序执行后的寄存器和内存，检查是否正确执行

#### 测试使用的汇编程序

如果要手动进行实验，[点击此处下载bin](kernel.bin)，将得到的 .bin 文件写入 BaseRAM。

[点击此处下载汇编程序](supervisor_la.zip)

如果要自行编译，可以使用提供的编译环境和程序进行编译。