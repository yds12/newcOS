; this comes right after the boot sector, and just calls the kernel

bits 32

; DEBUG
;mov ax, 0x4061
;mov word [0xb800], ax 
;jmp $

;mov ax, 0xb800
;mov es, ax
;mov ax, 0x4061
;mov word [es:0x0000], ax 
;jmp $

extern kmain
call kmain
jmp $

