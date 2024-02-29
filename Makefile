# Makefile help:
#
# $@ means the target file (the rule name)
# $< means the first dependency (after the rule name)
# $^ means all dependencies
# := assigns immediately at the start, and = assigns lazily

CC:=gcc
AS:=nasm
LINKER:=ld
QEMU:=qemu-system-x86_64
CFLAGS:=-m32 -fno-pic -ffreestanding -I include -Wall -Wextra -Wpedantic -Werror

BUILD_DIR:=build
KERNEL_DIR:=kernel
KERNEL_C:=$(wildcard $(KERNEL_DIR)/*.c)
KERNEL_C_OBJ:=$(patsubst $(KERNEL_DIR)/%.c,$(BUILD_DIR)/%.o, $(KERNEL_C))
KERNEL_ASM:=$(KERNEL_DIR)/entry.asm $(KERNEL_DIR)/paging.asm
KERNEL_ASM_OBJ:=$(patsubst $(KERNEL_DIR)/%.asm,$(BUILD_DIR)/%.o, $(KERNEL_ASM))
DRIVER_DIR:=driver
DRIVER_C:=$(wildcard $(DRIVER_DIR)/*.c)
DRIVER_OBJ:=$(patsubst $(DRIVER_DIR)/%.c,$(BUILD_DIR)/%.o, $(DRIVER_C))
OBJS:=$(KERNEL_C_OBJ) $(KERNEL_ASM_OBJ) $(DRIVER_OBJ)
BOOT_ASM:=$(wildcard boot/*.asm)
OS_IMG:=$(BUILD_DIR)/newcos

# -d guest_errors,int
run: $(OS_IMG)
	$(QEMU) -m 256M -drive format=raw,file=$<

$(OS_IMG): $(BUILD_DIR)/boot.bin $(BUILD_DIR)/kernel.bin
	cat $^ > $@
	truncate -s 48K $(OS_IMG)

$(BUILD_DIR)/boot.bin: $(BOOT_ASM)
	$(AS) -f bin -o $@ $<

$(BUILD_DIR)/kernel.bin: $(BUILD_DIR)/entry.o $(BUILD_DIR)/kernel.o $(BUILD_DIR)/ioport.o $(BUILD_DIR)/interrupt.o \
    $(BUILD_DIR)/vga.o $(BUILD_DIR)/keyboard.o $(BUILD_DIR)/mmap.o $(BUILD_DIR)/paging.o $(BUILD_DIR)/vmm.o
	$(LINKER) -m elf_i386 --oformat binary -Ttext 0x10000 -o $@ $^

# TODO why is this not working?
# $(BUILD_DIR)/kernel.bin: $(OBJS)
# 	$(LINKER) -m elf_i386 --oformat binary -Ttext 0x10000 -o $@ $^

$(KERNEL_ASM_OBJ): $(BUILD_DIR)/%.o: $(KERNEL_DIR)/%.asm
	$(AS) -f elf32 -o $@ $<

$(KERNEL_C_OBJ): $(BUILD_DIR)/%.o: $(KERNEL_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(DRIVER_OBJ): $(BUILD_DIR)/%.o: $(DRIVER_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(BUILD_DIR)/*

