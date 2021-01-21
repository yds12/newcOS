bits 16      ; 16 bit instructions
org 0x7c00   ; assume program will be loaded here

; address where the kernel should be loaded in memory
; (this will go to the segment register, so the actual
; address is this times 16)
KERNEL_OFFSET equ 0x1000

; setup a temporary stack (for push, call, ret, etc.)
mov bp, 0x9000
mov sp, bp

; setup video mode
mov ah, 0x00
mov al, 0x03      ; 80x25 text
int 0x10          ; BIOS interrupt

; print welcome msg
mov si, msg_hello
call print

; unfortunately in nasm relative paths are w.r.t.
; the working directory (from where we called nasm)
%include "boot/disk.asm"

call prepare32
jmp $ ; infinite loop

%include "boot/gdt.asm"
%include "boot/print.asm"

prepare32:
  cli                    ; disable BIOS interrupts
  lgdt [gdt_descriptor]  ; load GDT

  mov eax, cr0           ; enable protected mode
  or  al, 1
  mov cr0, eax

  jmp CODE_SEG:start32   ; far jump

; from here on, 32 bit instructions
bits 32
start32:
  mov ax, DATA_SEG       ; update segment registers
  mov ds, ax
  mov ss, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  mov ebp, 0x90000       ; setup another stack
  mov esp, ebp

; Since now we are in a flat memory mode,
; an address xxx:0x0000 becomes xxx*16
; (the real memory address is the value of the segment multiplied by 
; 16 and added to the offset)
  call KERNEL_OFFSET * 16  ; give control to Kernel
  jmp $                    ; loop if kernel returns

; padding
times (510 - ($ - $$)) db 0   ; $: current offset
                              ; $$: address of the current section
                              ; for whatever reason, nasm says (510 - $) is not a constant
dw 0xaa55  ; magic word

