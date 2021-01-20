# $@ means the target file (the rule name)
# $< means the first dependency (after the rule name)
# $^ means all dependencies

run: newcos.bin
	qemu-system-x86_64 -drive format=raw,file=$<

newcos.bin: boot.bin kernel.bin
	cat $^ > $@

boot.bin: boot.asm
	nasm -f bin -o $@ $<

kernel.bin: kernel-entry.o kernel.o
	ld -m elf_i386 -o $@ -Ttext 0x1000 $^ --oformat binary

kernel-entry.o: kernel-entry.asm
	nasm -f elf -o $@ $<

kernel.o: kernel.c
	gcc -m32 -fno-pic -ffreestanding -c $< -o $@

clean:
	rm *.bin *.o

