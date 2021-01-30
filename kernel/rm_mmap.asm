; We want our memory map function to be called by the kernel, go into real
; mode, do the memory mapping via BIOS and then return to the kernel in
; protected mode.

bits 32

; Make it visible to the kernel
global rm_mmap

section .bss
BASE_PTR: resd 1
STACK_PTR: resd 1
DATA_SEG: resd 1
MEMTAB: resd 1

section .text

; Entry point of the function
rm_mmap:

  ; Since we are going to real mode then back, it is better to save the stack
  mov eax, ebp
  mov [BASE_PTR], eax
  mov eax, esp
  mov [STACK_PTR], eax

  ; Save segment register
  mov ax, ds
  mov [DATA_SEG], ax

bits 16
  ; create a temporary 16-bit stack
  mov bp, 0x9000
  mov sp, bp

  ; disable protected mode
  mov eax, cr0
  and al, 0xFE  ; zeroes out last bit of al 
  xor ebx, ebx

  ; Memory Mapping function
  ; ...
  mov [MEMTAB], word 0xCCDD

  ; Now we need to re-enter protected mode
  ; disable BIOS interrupts
  cli

  ; re-enable protected mode
  mov eax, cr0
  or  al, 1
  mov cr0, eax

bits 32
  ; restore segment registers
  mov ax, [DATA_SEG]
  mov ds, ax
  mov ss, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  ; Restore the stack
  mov ebp, [BASE_PTR]
  mov esp, [STACK_PTR]

  ; Address of the memory table is returned
  mov eax, [MEMTAB]

  ; the calling address should now be in the top of the stack
  ret
