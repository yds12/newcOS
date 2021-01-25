# $@ means the target file (the rule name)
# $< means the first dependency (after the rule name)
# $^ means all dependencies

ODIR = build/
QEMU = qemu-system-x86_64
CC = gcc
CFLAGS = -m32 -fno-pic -ffreestanding -I include

# -d guest_errors,int
run: $(ODIR)newcos
	$(QEMU) -drive format=raw,file=$<

$(ODIR)newcos: $(ODIR)boot.bin $(ODIR)kernel.bin
	cat $^ > $@
	truncate -s 48K $(ODIR)newcos

$(ODIR)boot.bin: boot/boot.asm boot/disk.asm boot/gdt.asm boot/print.asm
	nasm -f bin -o $@ $<

$(ODIR)kernel.bin: $(ODIR)kernel-entry.o $(ODIR)kernel.o $(ODIR)ioport.o $(ODIR)interrupt.o \
    $(ODIR)vga.o $(ODIR)keyboard.o
	ld -m elf_i386 --oformat binary -Ttext 0x10000 -o $@ $^

$(ODIR)kernel-entry.o: boot/kernel-entry.asm
	nasm -f elf -o $@ $<

$(ODIR)kernel.o: kernel/kernel.c
	$(CC) $(CFLAGS) -c $< -o $@

$(ODIR)interrupt.o: kernel/interrupt.c
	$(CC) $(CFLAGS) -c $< -o $@

$(ODIR)ioport.o: driver/ioport.c
	$(CC) $(CFLAGS) -c $< -o $@

$(ODIR)vga.o: driver/vga.c
	$(CC) $(CFLAGS) -c $< -o $@

$(ODIR)keyboard.o: driver/keyboard.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm build/*

