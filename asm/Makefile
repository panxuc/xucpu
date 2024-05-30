GCCPREFIX?=loongarch32r-linux-gnusf-

override FLAGS += -nostdinc -nostdlib -fno-builtin -mabi=ilp32s -g

CC :=$(GCCPREFIX)gcc
LD      := $(GCCPREFIX)ld
AR      := $(GCCPREFIX)ar
OBJCOPY := $(GCCPREFIX)objcopy
OBJDUMP := $(GCCPREFIX)objdump

SRC   := $(wildcard *.s)
BINS  := $(patsubst %.s, %.bin, $(SRC))

all: $(BINS)

%.bin: %.elf
	$(OBJCOPY) -j .text -O binary $^ $@

%.elf: %.s
	$(CC) $(FLAGS) -Ttext 0x80100000 -o $@ $^

