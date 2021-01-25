; this comes right after the boot sector, and just calls the kernel

bits 32

extern kmain
call kmain
jmp $

; some initialization required by the kernel
; such as interrupt handlers, etc.
%include "kernel/isr.asm"
%include "kernel/irq.asm"

