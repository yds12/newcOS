# $@ means the target file (the rule name)
# $< means the first dependency (after the rule name)
# $^ means all dependencies

BDIR = build/
QEMU = qemu-system-x86_64
CC = gcc
CFLAGS = -m32 -fno-pic -ffreestanding -I include

run: $(BDIR)newcos
	$(QEMU) -drive format=raw,file=$<

$(BDIR)newcos: $(BDIR)boot.bin $(BDIR)kernel.bin
	cat $^ > $@

$(BDIR)boot.bin: boot/boot.asm boot/disk.asm boot/gdt.asm boot/print.asm
	nasm -f bin -o $@ $<

$(BDIR)kernel.bin: $(BDIR)kernel-entry.o $(BDIR)kernel.o $(BDIR)ioports.o
	ld -m elf_i386 --oformat binary -Ttext 0x1000 -o $@ $^

$(BDIR)kernel-entry.o: boot/kernel-entry.asm
	nasm -f elf -o $@ $<

$(BDIR)kernel.o: kernel/kernel.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BDIR)ioports.o: drivers/ioports.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm build/*

