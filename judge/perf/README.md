#### 测试说明

本实验需要实现一个 32 位 LoongArch CPU，支持LoongArch-C3指令集的 22 条指令：addi.w add.w sub.w lu12i.w pcaddu12i or ori andi and xor srli.w slli.w jirl b beq bne bl st.w ld.w st.b ld.b mul.w。测试器将利用高负载测试程序对CPU功能进行验证。

CPU实现要求与基础功能测试相同。

#### 测试步骤

1. 将拨码开关设置为0
2. Kernel下载到BaseRAM中
3. 单击复位按钮
4. 模拟Term程序连接串口，等待Kernel启动时的欢迎信息
5. 用G命令执行测试程序
6. 用R和D命令读取用户程序执行后的寄存器和内存，检查是否正确执行

#### 测试使用的汇编程序

如果要手动进行实验，[点击此处下载bin](kernel.bin)，将得到的 .bin 文件写入 BaseRAM。

[点击此处下载汇编程序](supervisor_la.zip)

如果要自行编译，可以使用提供的编译环境和程序进行编译。