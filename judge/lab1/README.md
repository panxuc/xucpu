#### 测试说明

本实验需要实现一个 32 位 LoongArch CPU，支持LoongArch-C1指令集的 6 条指令：addi.w lu12i.w add.w st.w ld.w bne。

自动化脚本会通过运行下面的汇编程序，对你的 CPU 进行正确性测试。

测试过程对CPU实现有如下要求：

1. 虚拟内存空间为0x80000000～0x807FFFFF，共8MB，要求整个内存空间均可读可写可执行。其中
   - 0x80000000～0x803FFFFF映射到BaseRAM；
   - 0x80400000～0x807FFFFF映射到ExtRAM。
2. CPU字节序为小端序。
3. CPU时钟使用外部时钟输入，50MHz / 11MHz两路时钟输入均可使用。
4. 在复位按钮按下时（高电平）CPU处于复位状态，松开后解除。
5. CPU复位后从0x80000000开始取指令执行。

#### 测试步骤

1. 将BaseRAM和ExtRAM重置，并将测试程序汇编成机器语言后写入到BaseRAM中。
2. 单击复位按钮。
3. 此时你的 CPU 应当从 BaseRAM 的起始地址开始执行程序，程序功能为循环斐波那契程序计算64次，结果分别写在ExtRAM的0x0 ~ 0x100中。
4. 等待 1s
5. 脚本读取 ExtRAM 中地址为 0x0 ~ 0x100 的数据，注意此处地址的单位与 CPU 中一致，均为字节

#### 测试使用的汇编程序

如果要手动进行实验，[点击此处下载bin](lab1.bin)，将得到的 .bin 文件写入 BaseRAM。

[点击此处下载汇编程序](lab1.S)

如果要自行编译，可以使用提供的编译环境和程序及以下命令进行编译。

```
loongarch32r-linux-gnusf-gcc -nostdinc -nostdlib -fno-builtin -mabi=ilp32s -Ttext 0x80000000 lab1.S -o lab1.elf
loongarch32r-linux-gnusf-objcopy -O binary -j .text lab1.elf lab1.bin
```

 
