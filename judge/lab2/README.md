#### 测试说明

本实验需要实现一个 32 位 LoongArch CPU，支持LoongArch-C2指令集的 14 条指令：addi.w add.w lu12i.w pcaddu12i or ori andi xor beq bne st.w ld.w st.b ld.b，及以下3类指令中的各随机1条指令：算术运算，slt sltu slti sltui；移位运算，sll.w srl.w sra.w srai.w；分支跳转，blt bge bltu bgeu。共17条指令，随机指令要求见账号邮件。

自动化脚本会通过运行下面附件的汇编程序，对你的 CPU 进行正确性测试。

测试过程对CPU实现有如下要求：

1. 虚拟内存空间为0x80000000～0x807FFFFF，共8MB，要求整个内存空间均可读可写可执行。其中
   - 0x80000000～0x803FFFFF映射到BaseRAM；
   - 0x80400000～0x807FFFFF映射到ExtRAM。
2. CPU字节序为小端序。
3. 支持串口信号txd/rxd，波特率9600，数据8位，停止1位，无校验位，串口控制器的地址映射按照监控程序要求。
4. CPU时钟使用外部时钟输入，50MHz / 11MHz两路时钟输入均可使用。
5. 在复位按钮按下时（高电平）CPU处于复位状态，松开后解除。
6. CPU复位后从0x80000000开始取指令执行。

#### 测试步骤

1. 将BaseRAM和ExtRAM重置，并将测试程序汇编成机器语言后写入到BaseRAM中，ExtRAM的0x100 ~ 0x10C地址中写入随机指令测试的测试参数。
2. 单击复位按钮，此时你的 CPU 应当从 BaseRAM 的起始地址开始执行程序。
3. CPU 先执行斐波那契程序，并在结束后发送结束信息 Fib Finish. ；同时脚本等待 CPU 发送斐波那契结束信息。
4. CPU 发送结束信息后等待串口输入字符"T"；脚本收到结束信息后发送"T"。
5. CPU 检测到串口输入"T"后，进行随机指令测试，并在结束后发送结束信息 All PASS!；同时脚本等待程序发送结束信息。
6. 脚本收到结束信息后，检查运行结果，结束测试。
7. 脚本检查斐波那契程序是读取 ExtRAM 中地址为 0x0 ~ 0x100 的数据，检查随机指令测试是读取 ExtRAM 中地址为 0x100 ~ 0x10c 的数据，注意此处地址的单位与 CPU 中一致，均为字节

#### 测试使用的汇编程序

如果要手动进行实验，[点击此处下载bin](lab2.bin)，将得到的 .bin 文件写入 BaseRAM。

[点击此处下载汇编程序](lab2.zip)

如果要自行编译，可以使用提供的编译环境和程序及以下命令进行编译。

```
loongarch32r-linux-gnusf-gcc -nostdinc -nostdlib -fno-builtin -mabi=ilp32s -Ttext 0x80000000 -Iinclude lab2.S -o lab2.elf
loongarch32r-linux-gnusf-objcopy -O binary -j .text lab2.elf lab2.bin
```

 
