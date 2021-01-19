# $@ means the target file (the rule name)
# $< means the first dependency (after the rule name)

run: boot.bin
	qemu-system-x86_64 -drive format=raw,file=$<

boot.bin: boot.asm
	nasm -f bin -o $@ $<

clean:
	rm *.bin
